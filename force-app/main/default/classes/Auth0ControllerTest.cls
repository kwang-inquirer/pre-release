@isTest
global class Auth0ControllerTest {
    @isTest
    private static void test_confirmPasswordReset() {
        Test.setMock(HttpCalloutMock.class, new Auth0Mock());
        
        Account acct = new Account(Name = 'Test Account');
        insert acct;

        Contact cont = new Contact(LastName = 'LastName', Email = 'test@test.com', AccountId = acct.Id);
        insert cont;

        Test.startTest();
            String success = Auth0Controller.confirmPasswordReset(cont.Id);
        Test.stopTest();

        System.assertEquals('SUCCESS', success, 'API Should pass back success');
    }

    @TestSetup
    static void setup() {
        Auth0ConnectionSettings__c setting = new Auth0ConnectionSettings__c(Default_Password__c = 'test', Audience__c = 'test', Client_Id__c = 'test', Client_Secret__c = 'test', Connection__c = 'test', Domain__c = 'test', Grant_Type__c = 'secret');
        insert setting;
    }
}