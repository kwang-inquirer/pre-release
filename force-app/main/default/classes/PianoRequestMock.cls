@isTest
public class PianoRequestMock implements HttpCalloutMock {
    private Integer code;
    
    public PianoRequestMock(Integer code) {
        this.code = code;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(200);
        resp.setBody(JSON.serialize(new Map<String, Object>{'code' => code}));
        return resp;
    }
}