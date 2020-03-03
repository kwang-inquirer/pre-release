public with sharing class SubscriptionBilling {
    public String Status {get;set;}
    public String DeliveryType {get;set;}
    public String Route {get;set;}
    public String District {get;set;}
    public String AutoPay {get;set;}
    public String Publication {get;set;}
    public String ServiceType {get;set;}
    public String LastBillDate {get;set;}
    public Decimal lastBillLen {get;set;}
    public Decimal LastBillAmt {get;set;}
    public String LastBillTerm {get;set;}
    public String LastPayDate {get;set;}
    public String LastPayAmt {get;set;}
    public String Expiration {get;set;}
    public Decimal Balance {get;set;}
    public String BalanceDate {get;set;}

    private transient Subscription subscription;

    public SubscriptionBilling(String subId) {
        this.subscription = new Subscription(subId);
        system.debug('==before initFields: '+ this.subscription);
        initFields();
    }

    private void initFields() {
        setSubscriptionFields();
        setLatestBillFields();
        setLatestJournalFields();
        setCurrentDeliveryScheduleFields();
    }  

    private void setSubscriptionFields() {
        Subscription__c sub = subscription.subscription;
        
        Status = sub.subscription_Status__c;
        AutoPay = sub.subscription_Auto_Renew__c ? 'Y' : 'N';
        Expiration = (sub.subscription_Current_Period_Ends_At__c != null) ? sub.subscription_Current_Period_Ends_At__c.format() : null;
        Balance = sub.Total_Liability__c;
        BalanceDate = Date.today().addDays(-1).format();
    }

    private void setLatestBillFields() {
        if (this.subscription.latestBill != null) {
            LastBillDate = subscription.latestBill.Bill_Date__c.format();
            LastBillLen = subscription.latestBill.Term__c;
            LastBillAmt = subscription.latestBill.Amount__c;
            LastBillTerm = 'Weeks';
        }
    }

    private void setLatestJournalFields() {
        if (subscription.latestJournal != null) {
            // return the latest journal entry date / amount
            LastPayDate = subscription.latestJournal.Entry_Date__c != null ? subscription.latestJournal.Entry_Date__c.format() : '';
            LastPayAmt = subscription.latestJournal.Credit__c != null ? String.valueof(subscription.latestJournal.Credit__c) : '';
        } 
        else if (subscription.latestRecurlyInvoice != null) {
            // return the latest recurly invoice date / amount
            LastPayDate = subscription.latestRecurlyInvoice.recurly_v2__Due_At__c != null ? subscription.latestRecurlyInvoice.recurly_v2__Due_At__c.format('MM/dd/yyyy') : '';
            LastPayAmt  = subscription.latestRecurlyInvoice.recurly_v2__Paid__c != null ? String.valueof(subscription.latestRecurlyInvoice.recurly_v2__Paid__c) : '';
        } else {
            // cover the fallout case
            LastPayDate = '';
            LastPayAmt = '';
        }
    }

    private void setCurrentDeliveryScheduleFields() {
        if (subscription.currentDeliverySchedule != null) {
            Route = subscription.currentDeliverySchedule.schedule.Routelookup__c;
            District = subscription.currentDeliverySchedule.schedule.Routelookup__r.District__c;
            Publication = subscription.currentDeliverySchedule.schedule.Offer_Product__r.Name;
            DeliveryType = subscription.currentDeliverySchedule.schedule.Offer_Product__r.Is_Digital__c ? 'Y' : 'N';
            ServiceType = subscription.currentDeliverySchedule.getScheduleForWeek();
        }
    }

    private String getServiceTypes(Delivery_Schedule__c deliverySchedule) {
        String types = '';
        types += (deliverySchedule.Day_Sunday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Monday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Tuesday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Wednesday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Thursday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Friday__c) ? 'Y' : 'N'; 
        types += (deliverySchedule.Day_Saturday__c) ? 'Y' : 'N'; 
        return types;
    }
}