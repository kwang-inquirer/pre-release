@isTest
global class SubscriptionApiTest {
    @isTest
    private static void test_SubscriptionApi() {
        TestDataFactory.createTestRecords(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Route__c route = [SELECT Id FROM Route__c LIMIT 1];

        Subscription__c sub = [SELECT Id, subscription_Status__c FROM Subscription__c LIMIT 1];
        sub.subscription_Status__c = 'Active';
        update sub;

        List<Delivery_Schedule__c> schedules = [SELECT Id FROM Delivery_Schedule__c];
        for (Delivery_Schedule__c schedule : schedules) {
            
            schedule.Day_Monday__c = true;
            schedule.Day_Tuesday__c = true;
            schedule.Day_Wednesday__c = true;
            schedule.Day_Thursday__c = true;
            schedule.Day_Friday__c = true;
            schedule.Day_Saturday__c = true;
            schedule.Day_Sunday__c = true;
            schedule.Routelookup__c = route.Id;
        }
        update schedules;

        Id transactionComplaintRecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        Transaction_Log__c log = new Transaction_Log__c(RecordTypeId = transactionComplaintRecordTypeId, Account__c = acct.Id, Date__c = Date.today(), Category__c = 'Complaint');
        insert log;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/subscription/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => acct.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            SubscriptionApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_SubscriptionApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/subscription/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            SubscriptionApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_SubscriptionApi_error_CustAccount() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/subscription/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            SubscriptionApi.post();
        Test.stopTest();
    }

}