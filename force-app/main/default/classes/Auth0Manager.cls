public with sharing class Auth0Manager {
    private Auth0ConnectionSettings__c settings;
    private String accessToken;

    public Auth0Manager() {
        settings = [
            SELECT Default_Password__c, Audience__c, Client_Id__c, Client_Secret__c, Connection__c, Domain__c, Grant_Type__c
            FROM Auth0ConnectionSettings__c 
            LIMIT 1
        ];
        accessToken = getAccessToken();
    }

    public AuthUser createUser(Map<String, Object> user) {
        user.put('connection', settings.Connection__c);
        user.put('email_verified', false);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Domain__c + '/api/v2/users');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody(JSON.serialize(user));
        HttpResponse response = Http.send(request);

        System.debug(request);
        System.debug(request.getHeader('Authorization'));
        System.debug(JSON.serialize(user));
        System.debug(response.getStatusCode());
        System.debug(response.getBody());        

        if (response.getStatusCode() != 201) {
            Map<String, Object> respObject = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String message = (String)respObject.get('message');
            if (message.contains('Password is too weak')) {
                throw new Auth0ManagerException('Failed to create user: password is too weak');
            }
            throw new Auth0ManagerException('Failed to create user');
        }

        return (AuthUser)JSON.deserialize(response.getBody(), AuthUser.class);
    }

    public String passwordChange(String email){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Domain__c + '/dbconnections/change_password');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(new Map<String, String>{
            'client_id' => settings.Client_Id__c, 
            'email' => email, 
            'connection' => 'Username-Password-Authentication'}));
        HttpResponse response = Http.send(request);

        System.debug(request);
        System.debug(request.getHeader('Authorization'));
        System.debug(response.getStatusCode());
        System.debug(response.getBody());        
        if(response.getStatusCode() == 200)
            return 'SUCCESS';
        if (response.getStatusCode() != 200) {
            throw new Auth0ManagerException('Failed to Request Password Change');
        }
        return 'FAILURE';
    }

    public List<AuthUser> getUsersByEmail(String email) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Domain__c + '/api/v2/users-by-email?email=' + EncodingUtil.urlEncode(email, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        HttpResponse response = Http.send(request);
        
        System.debug(request);
        System.debug(request.getHeader('Authorization'));
        System.debug(response.getStatusCode());
        System.debug(response.getBody());         

        if (response.getStatusCode() == 200) {
            return (List<AuthUser>)JSON.deserialize(response.getBody(), List<AuthUser>.class);
        } 

        return new List<AuthUser>();
    }

    /*
    public AuthUser updateUser(String userId, Map<String, Object> user) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Domain__c + '/api/v2/users/' + EncodingUtil.urlEncode(userId, 'UTF-8') + '?_HttpMethod=PATCH');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setBody(JSON.serialize(user));
        HttpResponse response = Http.send(request);

        System.debug(request);
        System.debug(request.getHeader('Authorization'));
        System.debug(JSON.serialize(user));
        System.debug(response.getStatusCode());
        System.debug(response.getBody());        

        if (response.getStatusCode() != 201) {
            Map<String, Object> respObject = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            String message = (String)respObject.get('message');
            if (message.contains('Password is too weak')) {
                throw new Auth0ManagerException('Password is too weak, please update your password');
            }
            throw new Auth0ManagerException('Failed to update user');
        }

        return (AuthUser)JSON.deserialize(response.getBody(), AuthUser.class);
    }
    */

    private String getAccessToken(){
        AccessTokenRequest accessTokenReq = new AccessTokenRequest(settings);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(settings.Domain__c + '/oauth/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(accessTokenReq));
        HttpResponse response = Http.send(request);

        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        String accessToken = results.get('access_token').toString();

        if (accessToken == null) {
            throw new Auth0ManagerException('Failed to authenticate');
        }
        
        return accessToken;
    }

    public class AccessTokenRequest {
        public String grant_type {get;set;}
        public String client_id {get;set;}
        public String client_secret {get;set;}
        public String audience {get;set;}

        public AccessTokenRequest(Auth0ConnectionSettings__c settings) {
            grant_type = settings.Grant_Type__c;
            client_id = settings.Client_Id__c;
            client_secret = settings.Client_Secret__c;
            audience = settings.Audience__c;
        }
    }

    public class AuthUser {
        public String email {get;set;}
        public String user_id {get;set;}
        public String password {get;set;}
    }

    public class Auth0ManagerException extends Exception {}
}