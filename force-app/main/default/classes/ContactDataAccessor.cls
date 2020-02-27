public class ContactDataAccessor {
    public static Contact getContactById(Id contactId) {
        return [ 
            SELECT Id, FirstName, LastName, AccountId, 
                (SELECT Id FROM Subscriptions__r WHERE subscription_Status__c = 'Active') 
            FROM Contact WHERE Id = :contactId
        ];
    }

    public static List<Contact> getContactsByEmail(String email) {
        return [
            SELECT Id, AccountId 
            FROM Contact 
            WHERE Email = :email
        ];
    }

    public static List<Contact> getContactsByPhone(String phone) {
        List<Contact> contacts;
        List<List<SObject>> searchList = [
            FIND :phone
            IN PHONE FIELDS
            RETURNING Contact(Id, AccountId, Account.BillingAddress, Account.Active_Subscriptions__c, FirstName, LastName)
        ];
        for (List<SObject> objects : searchList) {
            contacts = objects;
        }
        return contacts;
	}

    public static List<Contact> getContactsByPhoneAndBillingStreet(String phone, String street) {
		String houseWildcard = '%' + street + '%';
        List<Contact> contacts;
        List<List<SObject>> searchList = [
            FIND :phone
            IN PHONE FIELDS
            RETURNING Contact(Id, AccountId, Account.BillingAddress, Account.Active_Subscriptions__c, FirstName, LastName WHERE Account.BillingStreet LIKE :houseWildcard)
        ];
        for (List<SObject> objects : searchList) {
            contacts = objects;
        }
        return contacts;
	}
}