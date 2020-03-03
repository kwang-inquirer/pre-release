@isTest
global class RouteApiTest {
    @isTest
    private static void test_RouteApi() {
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


        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/route/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => acct.Id,
            'Route' => route.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            RouteApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_RouteApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/route/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            RouteApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_RouteApi_error_CustAccount() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/route/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => null,
            'Route' => 'test'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            RouteApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_RouteApi_error_Route() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/route/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => 'test',
            'Route' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            RouteApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_RouteApi_error_noDeliveries() {
        TestDataFactory.createTestRecords(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];
        Route__c route = [SELECT Id FROM Route__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/route/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => acct.Id,
            'Route' => route.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            RouteApi.post();
        Test.stopTest();
    }
}