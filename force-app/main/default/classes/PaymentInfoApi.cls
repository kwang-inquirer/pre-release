@RestResource(urlMapping='/paymentinfo/*')
global with sharing class PaymentInfoApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            PaymentInfoInput input = (PaymentInfoInput)JSON.deserialize(RestContext.request.requestbody.toString(), PaymentInfoInput.class);
            validate(input);
            res.responseBody = Blob.valueOf(JSON.serialize(new PaymentInfo()));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (PaymentInfoInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class PaymentInfoInput {
        public String SubId {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            return true;
        }
    }

    private class PaymentInfo {
        public String Account {get;set;}
        public String Publication {get;set;}
        public String TransDate {get;set;}
        public String CCAuto {get;set;}
        public String CCSingle {get;set;}
        public String BankDraftAuto {get;set;}
        public String BankDraftSingle {get;set;}
        

        public PaymentInfo() {
            this.Account = '1234567890';
            this.Publication = 'Test';
            this.TransDate = '01/01/2019';
            this.CCAuto = 'Y';
            this.CCSingle = 'Y';
            this.BankDraftAuto = 'Y';
            this.BankDraftSingle = 'Y';
        }
    }
}