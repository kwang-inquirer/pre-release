@isTest
global class HoldAndStopApiTest {
    @isTest
    private static void test_HoldAndStopApi_withTypeV() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'V',
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_withTypeR() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'R',
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_withStopReasonN() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'S',
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => 'N'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_withStopReasonS() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'S',
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => 'R'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }


    @isTest
    private static void test_HoldAndStopApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_error_SubId() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null,
            'Type' => 'S',
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => 'N'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_error_Type() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => null,
            'StartDate' => '01/01/2019',
            'EndDate' => '01/01/2019',
            'StopReason' => 'N'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_error_StartDate() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'S',
            'StartDate' => null,
            'EndDate' => '01/01/2019',
            'StopReason' => 'N'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_HoldAndStopApi_error_EndDate() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/holdandstop/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Type' => 'S',
            'StartDate' => '01/01/2019',
            'EndDate' => null,
            'StopReason' => 'N'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            HoldAndStopApi.post();
        Test.stopTest();
    }
}