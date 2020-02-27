@isTest
global class ServiceInfoApiTest {
    @isTest
    private static void test_ServiceInfoApi() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id, subscription_Status__c FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/serviceinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ServiceInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_ServiceInfoApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/serviceinfo/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ServiceInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_ServiceInfoApi_error_SubId() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/serviceinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ServiceInfoApi.post();
        Test.stopTest();
    }
}