/*
* -----------------------------------------------------------
* Apex Class Name: Auth0ConnectionTest
* -----------------------------------------------------------
* Description: Tests Auth0Connection.apxc. Uses mock class - Auth0ConnectionMock.apxc
* -----------------------------------------------------------
* Created by: Mitchell McLaughlin, RelationEdge
*/
@isTest
private class Auth0ConnectionTest {
    @testSetup static void setup(){
    Auth0ConnectionSettings__c mockSettings = new Auth0ConnectionSettings__c(
            Default_Password__c = 'password',
            Audience__c = 'audience',
            Domain__c = 'domain',
            Grant_Type__c = 'grantType',
            Client_Id__c = 'clientId',
            Client_Secret__c = 'clientSecret',
            Connection__c = 'connection');
            insert mockSettings;
    }
    @isTest static void shouldGetUsers() {
       Auth0Connection auth0 = new Auth0Connection();
       auth0.getUser('test123');
       auth0.getUserIdByEmail('test123');
    }   

}