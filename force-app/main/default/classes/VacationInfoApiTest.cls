@isTest
global class VacationInfoApiTest {
    @isTest
    private static void test_VacationInfoApi() {
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

        Id transactionComplaintRecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Vacation').getRecordTypeId();
        Transaction_Log__c log = new Transaction_Log__c(RecordTypeId = transactionComplaintRecordTypeId, Subscription__c = sub.Id, Account__c = acct.Id, Date__c = Date.today(), Category__c = 'Vacation');
        insert log;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_noNextStart() {
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
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_error_SubId() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_error_InvalidSubId() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id, subscription_Status__c FROM Subscription__c LIMIT 1];
        Id subId = sub.Id;
        delete sub;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => subId
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_error_InvalidSubId_Inactive() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id, subscription_Status__c FROM Subscription__c LIMIT 1];
        sub.subscription_Status__c = 'INACTIVE';
        update sub;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_VacationInfoApi_error_InvalidSubId_Terminated() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id, subscription_Status__c FROM Subscription__c LIMIT 1];
        sub.subscription_Status__c = 'TERMINATED';
        update sub;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/vacationinfo/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'SubId' => sub.Id
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            VacationInfoApi.post();
        Test.stopTest();
    }
}