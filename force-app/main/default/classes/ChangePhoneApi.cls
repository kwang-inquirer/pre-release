@RestResource(urlMapping='/changephone/*')
global with sharing class ChangePhoneApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            ChangePhoneInput input = (ChangePhoneInput)JSON.deserialize(RestContext.request.requestbody.toString(), ChangePhoneInput.class);
            validate(input);
            updatePhone(input);
            res.responseBody = Blob.valueOf(JSON.serialize(true));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (ChangePhoneInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private static void updatePhone(ChangePhoneInput input) {
        Subscription__c activeSub = [SELECT Id, Contact__r.Id, Contact__r.Phone FROM Subscription__c WHERE subscription_Account__c = :input.CustAccount AND subscription_Status__c = 'Active' ];
        activeSub.Contact__r.Phone = input.NewPhone;
        update activeSub.Contact__r;
    }

    private class ChangePhoneInput {
        public String CustAccount {get;set;}
        public String NewPhone {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(CustAccount)) {
                return false;
            }
            else if (String.isEmpty(NewPhone)) {
                return false;
            }
            return true;
        }
    }
}