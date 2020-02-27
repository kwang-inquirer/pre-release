@isTest
global class BillingInfoApiTest {
    @isTest
    private static void test_BillingInfoApi() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            BillingInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_BillingInfoApi_errorJson() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            BillingInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_BillingInfoApi_errorSubId() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            BillingInfoApi.post();
        Test.stopTest();
    }
}