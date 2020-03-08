@isTest
global class RecurlyApiMock implements HttpCalloutMock {
    private Integer statusCode;
    private String body;
    private String invoiceBodyTest = '<invoice><uuid>37c0057d2f641f4e2fcbda4b5b833633</uuid><state>paid</state><invoice_number type="integer">1007</invoice_number><type>charge</type><total_in_cents type="integer">5274</total_in_cents></invoice>';

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
        } else if (req.getEndpoint().contains('/invoices/')) {
            res.setStatusCode(statusCode != null ? statusCode : 200);
            res.setBody((body != null) ? body : invoiceBodyTest);
        }

        return res;
    }
}