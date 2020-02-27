@isTest
global class Auth0Mock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        if (req.getEndpoint().contains('/oauth/token')) {
            res.setStatusCode(200);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'access_token' => 'test'
            }));
        } else if (req.getEndpoint().contains('/api/v2/users')) {
            res.setStatusCode(201);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'email' => 'test@test.com',
                'user_id' => 'test'
            }));
        } else if (req.getEndpoint().contains('/users-by-email?email=')) {
            res.setStatusCode(201);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'email' => 'test@test.com',
                'user_id' => 'test'
            }));
        } else if (req.getEndpoint().contains('/dbconnections/change_password')) {
            res.setStatusCode(200);
        }

        return res;
    }
}