/*
* -----------------------------------------------------------
* Apex Class Name: Auth0Connection
* -----------------------------------------------------------
* Description: This class manages the connection to Auth0 
* including user/status management.
* -----------------------------------------------------------
* Created by: Mitchell McLaughlin, RelationEdge
*/
public class Auth0Connection {
    string defaultPassword;
    string connection;
    string domain;
    string grantType;
    string clientId;
    string clientSecret;
    string audience;
    string accessToken; 
    
    public Auth0Connection(){
        Auth0ConnectionSettings__c settings = [SELECT Default_Password__c, Audience__c, Client_Id__c,
                                               Client_Secret__c, Connection__c, Domain__c, Grant_Type__c
                                               FROM Auth0ConnectionSettings__c LIMIT 1];
        defaultPassword = settings.Default_Password__c;
        audience = settings.Audience__c;
        domain = settings.Domain__c;
        grantType = settings.Grant_Type__c;
        clientId = settings.Client_Id__c;
        clientSecret = settings.Client_Secret__c;
        connection = settings.Connection__c;
        accessToken = getAccessToken();
    }
    /*Query Auth0 for Id. If null, create. Return Id*/
    public String getUser(string email){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(domain + '/api/v2/users');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody('{"email":"' + email + '", "password":"' + defaultPassword + '", "connection":"' + connection + '", "email_verified": false}');
        HttpResponse response = Test.isRunningTest() ? Auth0ConnectionMock.getUser(request) : http.send(request);
        System.debug(response.getBody());        
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        Object responseCode = results.get('message');
        
        switch on response.getStatusCode(){
            /*User Created*/
            when 201{
                return results.get('user_id').toString();
            }
            /*User Exists*/
            when 409{
                return getUserIdByEmail(email);
            }
            when else{
                System.debug(response.getBody());
                throw new Auth0Exception('Unexpected response from Auth0 API Callout. Location: Auth0Connection.apxc.');
            }
        }
    }
    
    public String getUserIdByEmail(String userId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(domain + '/api/v2/users-by-email?email=' + userId);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse response = Test.isRunningTest() ? Auth0ConnectionMock.getUser(request) : http.send(request);
        return getParsedValue(response.getBody(), 'user_id');
        
    }
    
    public String getAccessToken(){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(domain + '/oauth/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"grant_type": "'+grantType+'","client_id": "'+clientId+'","client_secret": "'+clientSecret+'","audience": "' + audience + '"}');
        HttpResponse response = Test.isRunningTest() ? Auth0ConnectionMock.getAccessToken(request) : http.send(request);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        return results.get('access_token').toString();
    }
    
    private string getParsedValue(string jsonBody, string fieldName){
        JSONParser parser = JSON.createParser(jsonBody);
        while(parser.getCurrentName() != fieldName){
            parser.NextToken();
        }
        parser.NextToken();
        return parser.getText();
    }
    
    public class Auth0Exception extends Exception {}
}