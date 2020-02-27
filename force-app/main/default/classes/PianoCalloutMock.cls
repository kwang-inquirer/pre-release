@isTest
global class PianoCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        String trackingId = '';
        String endpoint = req.getEndpoint();
        List<String> params = endpoint.Split('&');
        for (String param : params) {
            if (param.contains('tracking_id')) {
                trackingId = param.substring(param.indexOf('=')+1, param.length());
            }
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');

        if (trackingId == 'pass') {
            res.setBody('{"code":"200"}');
            res.setStatusCode(200);
        } else {
            res.setBody('{"code":"401","message":"Tracking Id is invalid"}');
            res.setStatusCode(200);
        }

        return res;
    }
}