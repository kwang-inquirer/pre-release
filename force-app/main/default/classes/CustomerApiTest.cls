@isTest
global class CustomerApiTest {
    @isTest
    private static void test_CustomerApi_withoutHouse() {
        Account acct = new Account(Name = 'Test Account', BillingStreet = '1234 Test Rd', BillingCity = 'Test City', BillingState = 'OH', BillingPostalCode = '12345');
        insert acct;

        Contact cont = new Contact(LastName = 'LastName', Phone = '555-555-5555', AccountId = acct.Id);
        insert cont;

       Test.setFixedSearchResults(new List<Id>{cont.Id});

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustPhone' => '555-555-5555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        System.debug([SELECT Id, Phone FROM Contact]);

        Test.startTest();
            CustomerApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CustomerApi_withHouse() {
        Account acct = new Account(Name = 'Test Account', BillingStreet = '1234 Test Rd', BillingCity = 'Test City', BillingState = 'OH', BillingPostalCode = '12345');
        insert acct;

        Contact cont = new Contact(LastName = 'LastName', Phone = '5555555555');
        insert cont;

        Test.setFixedSearchResults(new List<Id>{cont.Id});

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustPhone' => '5555555555',
            'CustHouse' => '1234 Test Rd'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CustomerApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CustomerApi_error_Json() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CustomerApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CustomerApi_error_CustPhone() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/customer/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'CustAccount' => null,
            'NewPhone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CustomerApi.post();
        Test.stopTest();
    }

}