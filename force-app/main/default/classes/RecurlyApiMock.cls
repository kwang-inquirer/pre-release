@isTest
global class RecurlyApiMock implements HttpCalloutMock {
    private Integer statusCode;
    private String body;

    global RecurlyApiMock() {
    
    }

    global RecurlyApiMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
    }

	global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (req.getEndpoint().contains('/purchases')) {
            res.setStatusCode(statusCode != null ? statusCode : 201);
            if (body != null) {
                res.setBody(body);
            }
        } else if (req.getEndpoint().contains('/accounts/')) {
            res.setStatusCode(statusCode != null ? statusCode : 200);
            if (body != null) {
                res.setBody(body);
            }
        } else if (req.getEndpoint().contains('/refund')) {
            res.setStatusCode(statusCode != null ? statusCode : 201);
            if (body != null) {
                res.setBody(body);
            }
        } 

        return res;
    }
}