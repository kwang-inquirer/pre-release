@RestResource(urlMapping='/newsubscription/*')
global with sharing class NewSubscriptionInfoApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            SubscriptionInput input = (SubscriptionInput)JSON.deserialize(RestContext.request.requestbody.toString(), SubscriptionInput.class);
            validate(input);
            res.responseBody = Blob.valueOf(JSON.serialize(new Subscription()));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (SubscriptionInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class SubscriptionInput {
        public String CustAccount {get;set;}
        public String PubCode {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(CustAccount)) {
                return false;
            }
            if (String.isEmpty(PubCode)) {
                return false;
            }
            return true;
        }
    }

    private class Subscription {
        public String SubId {get;set;}
        public String Frequency {get;set;}
        public String Terms {get;set;}

        public Subscription() {
            this.SubId = '1234567890';
            this.Frequency = 'YYNNNYY';
            this.Terms = 'Test';
        }
    }
}