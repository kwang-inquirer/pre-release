public with sharing class Subscription {
    public Subscription__c subscription {get;set;}
    
    private List<Billing__c> billings;
    private List<Journal__c> journals;
    private List<Delivery_Schedule__c> deliverySchedules;
    private List<recurly_v2__Recurly_Invoice__c> recurlyInvoices;

    private static String todaysDayOfWeek = System.now().format('EEEE');
    private List<String> recurlyAcctIDs = new List<String>();
    
    public Subscription(String subId) {
        recurlyAcctIDs = RecurlyAccountDataAccessor.getRecurlyAcctIDsBySubscriptionId(subId);
        initObjects(subId);
    }

    public Billing__c latestBill {
        get {
            if (latestBill == null && billings != null && !billings.isEmpty()) {
                latestBill = billings[0]; // latest should be first in array due to order by
            }
            return latestBill;
        } private set;
    }

    public Journal__c latestJournal {
        get {
            if (latestJournal == null && journals != null && !journals.isEmpty()) {
                latestJournal = journals[0]; // latest should be first in array due to order by
            }
            return latestJournal;
        } private set;
    }

    public recurly_v2__Recurly_Invoice__c latestRecurlyInvoice {
        get {
            if (latestRecurlyInvoice == null && recurlyInvoices != null && !recurlyInvoices.isEmpty()) {
                latestRecurlyInvoice = recurlyInvoices[0];
            }
            return latestRecurlyInvoice;
        } private set;
    }

    public DeliverySchedule currentDeliverySchedule {
        get {
            if (currentDeliverySchedule == null && deliverySchedules != null && !deliverySchedules.isEmpty()) {
                for (Delivery_Schedule__c deliverySchedule : deliverySchedules) {
                    currentDeliverySchedule = new DeliverySchedule(deliverySchedule);
                    if (currentDeliverySchedule.isScheduledForToday()) {
                        break;
                    }
                }
            }
            return currentDeliverySchedule;
        } private set;
    }

    private void initObjects(Id subId) {
        this.subscription = [
            SELECT Id, subscription_Current_Period_Ends_At__c, subscription_Status__c, subscription_Auto_Renew__c, Total_Liability__c
            FROM Subscription__c
            WHERE Id = :subId
        ];

        this.billings = [
            SELECT Id, Bill_Date__c, Term__c, Amount__c
            FROM Billing__c
            WHERE Subscription__c = :subId
            ORDER BY Bill_Date__c DESC NULLS LAST
        ];
		
        this.journals = [
            SELECT Id, Entry_Date__c, Credit__c, Entry_Type__c
            FROM Journal__c
            WHERE Subscription__c = :subId
            AND Entry_Type__c = 'Cash'
            ORDER BY Entry_Date__c DESC NULLS LAST
        ];

        // paid invoice associated with recurly account
        this.recurlyInvoices = [
            SELECT Id, LastModifiedDate,
            recurly_v2__Due_At__c,
            recurly_v2__Account__c,
            recurly_v2__Invoice_Type__c,
            recurly_v2__Recurly_Account__c,
            recurly_v2__Status__c,
            recurly_v2__Total__c,
            recurly_v2__Paid__c
            FROM recurly_v2__Recurly_Invoice__c
            WHERE recurly_v2__Recurly_Account__c IN :recurlyAcctIDs
            AND recurly_v2__Status__c = 'Paid'
            ORDER BY LastModifiedDate DESC
        ];

        List<Delivery_Schedule__c> deliverySchedules = [
            SELECT Id, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c, Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c, 
                Routelookup__c, Routelookup__r.District__c, Offer_Product__r.Name, Offer_Product__r.Is_Digital__c
            FROM Delivery_Schedule__c
            WHERE subscription_Subscription__c = :subId
        ];
    }
}