@isTest
global class LocationApiTest {
    @isTest
    private static void test_LocationApi() {
        Account acct = new Account(Name = 'Test Account', BillingStreet = '1234 Test Rd', BillingCity = 'Test City', BillingState = 'OH', BillingPostalCode = '12345');
        insert acct;

        Contact cont = new Contact(LastName = 'LastName', Phone = '555-555-5555', AccountId = acct.Id);
        insert cont;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/location/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'Phone' => '555-555-5555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            LocationApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_LocationApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/location/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            LocationApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_LocationApi_error_Phone() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/location/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'Phone' => null
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            LocationApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_LocationApi_error_Phone_notFound() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/location/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'Phone' => '1234561234'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            LocationApi.post();
        Test.stopTest();
    }
}