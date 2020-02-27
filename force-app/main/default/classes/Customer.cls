public class Customer {
    public String CustId {get;set;}
    public String MultiSubs {get;set;}
    public String FirstName {get;set;}
    public String LastName {get;set;}
    public String Street {get;set;}
    public String City {get;set;}
    public String State {get;set;}
    public String Zip {get;set;}
    public String CCAccountCode {get;set;}

    public Customer(Contact cont) {
        this.CustId = cont.AccountId;
        this.FirstName = cont.FirstName;
        this.LastName = cont.LastName;
        this.MultiSubs = cont.Account.Active_Subscriptions__c > 1 ? 'Y' : 'N';
        this.Street = cont.Account.BillingAddress.getStreet();
        this.City = cont.Account.BillingAddress.getStreet();
        this.State = cont.Account.BillingAddress.getState();
        this.Zip = cont.Account.BillingAddress.getPostalCode();
    }

    public static List<Contact> getContacts(String phone, String house) {
        if (String.isEmpty(house)) {
            return ContactDataAccessor.getContactsByPhone(phone);
        } else {
            return ContactDataAccessor.getContactsByPhoneAndBillingStreet(phone, house);
        }
    }
}