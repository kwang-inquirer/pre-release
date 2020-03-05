@isTest
global class ChangePhoneApiTest {
    @isTest
    private static void test_ChangePhoneApi() {
        TestDataFactory.createTestRecords(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => acct.Id,
            'NewPhone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ChangePhoneApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_ChangePhoneApi_errorJson() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ChangePhoneApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_ChangePhoneApi_errorCustAccount() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => null,
            'NewPhone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ChangePhoneApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_ChangePhoneApi_errorNewPhone() {
        TestDataFactory.createTestRecords(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/sfdcCallingContact/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => acct.Id,
            'NewPhone' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            ChangePhoneApi.post();
        Test.stopTest();
    }
}