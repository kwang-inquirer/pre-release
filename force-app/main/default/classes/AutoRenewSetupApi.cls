@RestResource(urlMapping='/autorenewsetup/*')
global with sharing class AutoRenewSetupApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            AutoRenewSetupInput input = (AutoRenewSetupInput)JSON.deserialize(RestContext.request.requestbody.toString(), AutoRenewSetupInput.class);
            validate(input);
			try {
				Subscription__c sub = SubscriptionDataAccessor.getSubscription(input.SubId);
				sub.Auto_Renew_Tip__c = input.Tip;
				sub.subscription_Auto_Renew__c = true;
				update sub;
                res.responseBody = Blob.valueOf(JSON.serialize(true));
			} catch (Exception e) {
				throw new GenericException('No subscription found');
			}
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (AutoRenewSetupInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class AutoRenewSetupInput {
        public String SubId {get;set;}
        public Decimal Tip {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            if (Tip == null) {
                return false;
            }
            return true;
        }
    }
}