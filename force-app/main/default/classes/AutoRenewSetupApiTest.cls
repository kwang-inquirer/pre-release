@isTest
global class AutoRenewSetupApiTest {
    @isTest
    private static void test_autoRenewSetupApi() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Tip' => 5.00
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            AutoRenewSetupApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_autoRenewSetupApi_errorJson() {
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
            AutoRenewSetupApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_autoRenewSetupApi_errorSubId() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null,
            'Tip' => 5.00
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            AutoRenewSetupApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_autoRenewSetupApi_errorTip() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Tip' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            AutoRenewSetupApi.post();
        Test.stopTest();
    }
}