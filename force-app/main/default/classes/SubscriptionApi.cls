@RestResource(urlMapping='/subscription/*')
global with sharing class SubscriptionApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            SubscriptionInput input = (SubscriptionInput)JSON.deserialize(RestContext.request.requestbody.toString(), SubscriptionInput.class);
            validate(input);
            res.responseBody = Blob.valueOf(JSON.serialize(getSubscriptionInfo(input.CustAccount)));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (SubscriptionInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private static List<Subscription> getSubscriptionInfo(Id accountId) {
        Id transactionComplaintRecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        List<Transaction_Log__c> complaints = [SELECT Id, Date__c FROM Transaction_Log__c WHERE RecordTypeId = :transactionComplaintRecordTypeId AND Account__c = :accountId];
        List<Delivery_Schedule__c> activeDeliverySchedules = [SELECT Id, Routelookup__c, District__c, subscription_Subscription__r.Subscription_Amount__c, subscription_Subscription__c, subscription_Subscription__r.subscription_Auto_Renew__c, subscription_Subscription__r.subscription_Status__c FROM Delivery_Schedule__c WHERE subscription_Subscription__r.subscription_Account__c = :accountId AND subscription_Subscription__r.subscription_Status__c = 'Active'];
        List<Subscription> subs = new List<Subscription>();
        for (Delivery_Schedule__c deliverySchedule : activeDeliverySchedules) {
            subs.add(new Subscription(deliverySchedule, complaints));
        }
        return subs;
    }

    private class SubscriptionInput {
        public String CustAccount {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(CustAccount)) {
                return false;
            }
            return true;
        }
    }

    private class Subscription {
        public String Status {get;set;}
        public String RouteId {get;set;}
        public String District {get;set;}
        public String BillMethod {get;set;}
        public Decimal Rate {get;set;}
        public Integer ComplaintCount {get;set;}
        public String Id {get;set;}
        public List<Date> LastComplaints {get;set;}

        public Subscription(Delivery_Schedule__c deliverySchedule, List<Transaction_Log__c> complaints) {
            Boolean autoRenew = deliverySchedule.subscription_Subscription__r.subscription_Auto_Renew__c;
            String billMethod = (autoRenew) ? 'Credit Card' : 'Manual';
            Integer complaintCount = (complaints != null) ? complaints.size() : 0;
            List<Date> lastThreeComplaintDates = getLastComplaints(complaints, 3);
            this.Status = deliverySchedule.subscription_Subscription__r.subscription_Status__c;
            this.RouteId = deliverySchedule.Routelookup__c;
            this.District = deliverySchedule.District__c;
            this.BillMethod = billMethod;
            this.Rate = deliverySchedule.subscription_Subscription__r.Subscription_Amount__c;
            this.ComplaintCount = complaintCount;
            this.Id = deliverySchedule.subscription_Subscription__c;
            this.LastComplaints = lastThreeComplaintDates;
        }

        private List<Date> getLastComplaints(List<Transaction_Log__c> complaints, Integer numComplaintsToShow) {
            if (complaints == null || complaints.isEmpty()) {
                return null;
            }

            Integer counter = 0;
            List<Date> dates = new List<Date>();
            for (Transaction_Log__c complaint : complaints) {
                if (counter < numComplaintsToShow) {
                    break;
                }
                dates.add(complaint.Date__c);
            }
            return dates;
        }
    }
}