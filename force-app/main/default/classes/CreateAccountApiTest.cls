@isTest
global class CreateAccountApiTest {
    @isTest
    private static void test_CreateAccountApi() {
        TestDataFactory.createTestRecords(1);
        Account acct = [SELECT Id FROM Account LIMIT 1];

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       
        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_errorJson() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       
        req.requestBody = Blob.valueof('{sfesef}sfesf');
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_lastName() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => null,
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_houseNum() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => null,
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_preDirection() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => null,
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_street() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => null,
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_streetType() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => null,
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_postDirection() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => null,
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_apt() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => null,
            'City' => 'test',
            'State' => 'CA',
            'Zip' => '12345',
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }

    @isTest
    private static void test_CreateAccountApi_error_zip() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/newaccount/';       

        req.requestBody = Blob.valueof(JSON.serialize(new Map<String, Object>{
            'FirstName' => 'test',
            'LastName' => 'test',
            'HouseNum' => 'test',
            'PreDirection' => 'test',
            'Street' => 'test',
            'StreetType' => 'test',
            'PostDirection' => 'test',
            'Apt' => 'test',
            'City' => 'test',
            'State' => 'CA',
            'Zip' => null,
            'Phone' => '5555555555'
        }));
        RestContext.request = req; 
        RestContext.response= res;

        Test.startTest();
            CreateAccountApi.post();
        Test.stopTest();
    }
}