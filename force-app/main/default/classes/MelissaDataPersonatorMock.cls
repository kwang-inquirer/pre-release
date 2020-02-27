@isTest
global class MelissaDataPersonatorMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        return res;
    }
}