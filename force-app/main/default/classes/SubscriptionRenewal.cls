public with sharing class SubscriptionRenewal {
    private Map<Id, Subscription__c> subscriptionsById;
    private Map<Id, Offer__c> offersMap;

    private RecurlyApi recurlyApi;

    public SubscriptionRenewal(List<Subscription__c> subscriptions) {
        this.recurlyApi = new RecurlyApi();
        this.subscriptionsById = new Map<Id, Subscription__c>(subscriptions);
        this.offersMap = new Map<Id, Offer__c>(OfferDataAccessor.getSubscriptionDigitalOffers(subscriptionsById.keySet()));
    }

    public void processSubscriptions() {
        List<Log__c> logs = new List<Log__c>();
        List<Billing__c> billings = new List<Billing__c>();
        for (Subscription__c sub : subscriptionsById.values()) {
            try {
                createPurchase(sub);
                adjustSubscription(sub);
                billings.add(new Billing__c(Bill_Date__c = Date.today(), Amount__c = sub.subscription_Offer__r.Total_Amount__c, Subscription__c = sub.Id));
                sub.One_Time_Tip_Amount__c = 0;

                if (sub.Pending_Offer__c != null) {
                    sub.subscription_Offer__c = sub.Pending_Offer__c;
                    sub.Pending_Offer__c = null;
                    sub.Pending_Change_Date__c = null;
                }
            } catch (Exception e) {
                System.debug(e.getMessage() + ' ' + e.getStackTraceString());
                logs.add(new Log__c(Type__c = 'Subscription Renewal Exception', Subscription__c = sub.Id, Message__c = e.getMessage() + ' ' + e.getStackTraceString()));
            }
        }
        if (!subscriptionsById.isEmpty()) {
            update subscriptionsById.values();
        }
        if (!billings.isEmpty()) {
            insert billings;
        }
    }

    private void createPurchase(Subscription__c sub) {
        List<RecurlyApiObjects.AdjustmentDetails> adjustments = new List<RecurlyApiObjects.AdjustmentDetails>();
        adjustments.add(new RecurlyApiObjects.AdjustmentDetails(sub.subscription_Offer__r.Total_Amount__c * 100, 1, 'Subscription Amount'));
        if (sub.Auto_Renew_Tip__c != null && sub.Auto_Renew_Tip__c > 0) {
            adjustments.add(new RecurlyApiObjects.AdjustmentDetails(sub.Auto_Renew_Tip__c * 100, 1, 'Tip Amount'));
        } else if (sub.Auto_Renew_Tip__c != null && sub.One_Time_Tip_Amount__c > 0) {
            adjustments.add(new RecurlyApiObjects.AdjustmentDetails(sub.One_Time_Tip_Amount__c * 100, 1, 'Tip Amount'));
        }
        RecurlyApiObjects.Purchase purchase = new RecurlyApiObjects.Purchase(sub.Auto_Renew_Recurly_Account__r.recurly_v2__Code__c, adjustments, null);
        recurlyApi.createPurchase(purchase);
    }

    private void adjustSubscription(Subscription__c subscription) {
        Offer__c digitalOffer = offersMap.get(subscription.subscription_Offer__c);
        subscription.Outstanding_Credit__c = ((subscription.Outstanding_Credit__c != null) ? subscription.Outstanding_Credit__c : 0) + subscription.subscription_Offer__r.Total_Amount__c;
        subscription.subscription_Current_Period_Started_At__c = (subscription.subscription_Current_Period_Started_At__c != null) ? subscription.subscription_Current_Period_Started_At__c : Date.today();
        CreditCalculatorController.ApplyAdjustment(subscription, digitalOffer);
    }
}