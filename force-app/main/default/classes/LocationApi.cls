@RestResource(urlMapping='/location/*')
global with sharing class LocationApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            LocationInput input = (LocationInput)JSON.deserialize(RestContext.request.requestbody.toString(), LocationInput.class);
            validate(input);
            List<Contact> contacts = [SELECT Id, Account.BillingStreet FROM Contact WHERE Phone = :input.Phone LIMIT 1];
			if (contacts.isEmpty()) {
				throw new GenericException('No location found');
			}
            res.responseBody = Blob.valueOf(JSON.serialize(new Location(contacts[0])));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (LocationInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class LocationInput {
        public String Phone {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(Phone)) {
                return false;
            }
            return true;
        }
    }

    private class Location {
        public String House {get;set;}

        public Location(Contact cont) {
            this.House = cont.Account.BillingStreet;
        }
    }
}