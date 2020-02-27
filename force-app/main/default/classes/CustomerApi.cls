@RestResource(urlMapping='/customer/*')
global with sharing class CustomerApi {
    private static final String ERROR_NO_CUSTOMER_FOUND = 'No customer found';
    private static final String ERROR_INVALID_INPUT = 'Invalid input';

    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            CustomerApiInput input = (CustomerApiInput)JSON.deserialize(RestContext.request.requestbody.toString(), CustomerApiInput.class);
            validate(input);
			List<Contact> contacts = Customer.getcontacts(input.CustPhone, input.CustHouse);
			if (contacts.isEmpty()) {
				throw new GenericException(ERROR_NO_CUSTOMER_FOUND);
			}
            res.responseBody = Blob.valueOf(JSON.serialize(new Customer(contacts[0])));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (CustomerApiInput input) {
        if (!input.isValid()) {
            throw new GenericException(ERROR_INVALID_INPUT);
        }
    }

    private class CustomerApiInput {
        public String CustPhone {get;set;}
        public String CustHouse {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(CustPhone)) {
                return false;
            }
            return true;
        }
    }
}