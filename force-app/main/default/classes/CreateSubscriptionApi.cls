@RestResource(urlMapping='/createsubscription/*')
global with sharing class CreateSubscriptionApi {
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
        public String TypeId {get;set;}


        public Boolean isValid() {
            if (String.isEmpty(CustAccount)) {
                return false;
            }
            if (String.isEmpty(TypeId)) {
                return false;
            }
            return true;
        }
    }

    private class Subscription {
        public String Id {get;set;}

        public Subscription() {
            this.Id = '1234567890';
        }
    }
}