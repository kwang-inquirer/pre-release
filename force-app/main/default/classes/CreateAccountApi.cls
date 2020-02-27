@RestResource(urlMapping='/newaccount/*')
global with sharing class CreateAccountApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            CustomerAccount input = (CustomerAccount)JSON.deserialize(RestContext.request.requestbody.toString(), CustomerAccount.class);
            validate(input);
            Account acct = createAccount(input);
            createContact(input, acct);
            res.responseBody = Blob.valueOf(JSON.serialize(acct));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (CustomerAccount input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private static Account createAccount(CustomerAccount input) {
        String householdName = input.FirstName + ' ' + input.LastName + ' Household';
        List<String> streetInfo = new List<String>{input.HouseNum, input.PreDirection, input.Street, input.StreetType, input.PostDirection, input.Apt};
        String billingStreet = String.join(streetInfo, ' ');
        Account acct = new Account(Name = householdName, BillingStreet = billingStreet, BillingCity = input.City, BillingState = input.State, BillingPostalCode = input.Zip);
        insert acct;
        return acct;
    }

    private static Contact createContact(CustomerAccount input, Account acct) {
        Contact cont = new Contact(AccountId = acct.Id, FirstName = input.FirstName, LastName = input.LastName, Phone = input.Phone);
        insert cont;
        return cont;
    }

    private class CustomerAccount {
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String HouseNum {get;set;}
        public String PreDirection {get;set;}
        public String Street {get;set;}
        public String StreetType {get;set;}
        public String PostDirection {get;set;}
        public String Apt {get;set;}
        public String City {get;set;}
        public String State {get;set;}
        public String Zip {get;set;}
        public String Phone {get;set;}


        public Boolean isValid() {
            if (String.isEmpty(LastName)) {
                return false;
            }
            else if (String.isEmpty(HouseNum)) {
                return false;
            }
            else if (String.isEmpty(PreDirection)) {
                return false;
            }
            else if (String.isEmpty(Street)) {
                return false;
            }
            else if (String.isEmpty(StreetType)) {
                return false;
            }
            else if (String.isEmpty(PostDirection)) {
                return false;
            }
            else if (String.isEmpty(Apt)) {
                return false;
            }
            else if (String.isEmpty(Zip)) {
                return false;
            }
            return true;
        }
    }
}