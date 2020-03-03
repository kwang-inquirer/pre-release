/*
* -----------------------------------------------------------
* Apex Class Name: Auth0ConnectionMock
* -----------------------------------------------------------
* Description: This class is used for custom mock responses for auth0 callouts from Auth0ConnectionTest.apxc
* This class should not be used for anything else.
* -----------------------------------------------------------
* Created by: Mitchell McLaughlin, RelationEdge
*/

public class Auth0ConnectionMock{
    @TestVisible public static HTTPResponse getAccessToken(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"accessGranted123"}');
        res.setStatusCode(201);
        return res;
    }
    @TestVisible public static HTTPResponse getUser(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"user_id":"auth0Id123"}');
        res.setStatusCode(201);
        return res;
    }
}