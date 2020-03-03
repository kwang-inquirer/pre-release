@isTest
global class DeliveryIssueApiTest {
    @isTest
    private static void test_DeliveryIssueApi_delivery() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Resolution' => 'R',
            'IncidentDate' => '01/01/2019',
            'Compliant' => 'R'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_credit() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Resolution' => 'C',
            'IncidentDate' => '01/01/2019',
            'Compliant' => 'C'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_error_SubId() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null,
            'Resolution' => 'C',
            'IncidentDate' => '01/01/2019',
            'Compliant' => 'C'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_error_Resolution() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Resolution' => null,
            'IncidentDate' => '01/01/2019',
            'Compliant' => 'C'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_error_IncidentDate() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Resolution' => 'C',
            'IncidentDate' => null,
            'Compliant' => 'C'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_DeliveryIssueApi_error_Compliant() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id,
            'Resolution' => 'C',
            'IncidentDate' => '01/01/2019',
            'Compliant' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            DeliveryIssueApi.post();
        Test.stopTest();
    }
}