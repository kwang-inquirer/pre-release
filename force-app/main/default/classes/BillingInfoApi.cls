@RestResource(urlMapping='/billinginfo/*')
global with sharing class BillingInfoApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            BillingInfoInput input = (BillingInfoInput)JSON.deserialize(RestContext.request.requestbody.toString(), BillingInfoInput.class);
            validate(input);
			try {
				res.responseBody = Blob.valueOf(JSON.serialize(new SubscriptionBilling(input.SubId)));
			} catch (Exception e) {
				throw new GenericException('No subscription found');
			}
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (BillingInfoInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class BillingInfoInput {
        public String SubId {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            return true;
        }
    }
}