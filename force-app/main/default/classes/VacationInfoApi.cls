@RestResource(urlMapping='/vacationinfo/*')
global with sharing class VacationInfoApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            VacationInfoInput input = (VacationInfoInput)JSON.deserialize(RestContext.request.requestbody.toString(), VacationInfoInput.class);
            validate(input);
            res.responseBody = Blob.valueOf(JSON.serialize(new VacationInfo(input.SubId)));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            res.statusCode = 500;
        }
    }

    private static void validate (VacationInfoInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class VacationInfoInput {
        public String SubId {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            return true;
        }
    }

    private class VacationInfo {
        public Integer PubCount {get;set;}
        public String RestartOnly {get;set;}
        public String EarliestStop {get;set;}
        public String NextStart {get;set;}
        public String NextEnd {get;set;}

        public VacationInfo(Id subscriptionId) {
            Id transactionVacationHoldRecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Vacation').getRecordTypeId();
            List<Subscription__c> subscription = [SELECT Id, subscription_Offer__c FROM Subscription__c WHERE Id = :subscriptionId];
            if (subscription.isEmpty()) {
                throw new GenericException('No subscription found');
            }
            
            // any current or future vacations
            List<Transaction_Log__c> earliestVacationHold = [
                SELECT Id, Subscription__c, First_Date__c, Last_Date__c 
                FROM Transaction_Log__c 
                WHERE RecordTypeId = :transactionVacationHoldRecordTypeId 
                AND Subscription__c = :subscriptionId 
                ORDER BY First_Date__c DESC LIMIT 1
            ];
            // using First_Date__c and Last_Date__c from Transaction Log
            if (!earliestVacationHold.isEmpty()) {
                Transaction_Log__c transactionLog = earliestVacationHold[0];
                NextStart = transactionLog.First_Date__c != null ? transactionLog.First_Date__c.format() : '';
                NextEnd = transactionLog.Last_Date__c != null ? transactionLog.Last_Date__c.format() : '';           
            } else {
                NextStart = '';
                NextEnd   = '';              
            }

            List<Offer_Product__c> offerProducts = [SELECT Id FROM Offer_Product__c WHERE Offer__c = :subscription[0].subscription_Offer__c];
            List<Delivery_Schedule__c> deliverySchedules = DeliveryScheduleDataAccessor.getDeliveryScheduleBySubId(subscriptionId);            
            Date earliestStopDate = SubscriptionDelivery.getEarliestStopDate(deliverySchedules);

            RestartOnly = 'N';  // default value
            PubCount = offerProducts.size();
            EarliestStop = (earliestStopDate != null) ? earliestStopDate.format() : '';
        }
    }
}