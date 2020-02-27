public with sharing class ContactController {
    @AuraEnabled
    public static Contact getContactById(String contactId) {
        return [
            SELECT Id, Email, AccountId, Account.Name, Account.BillingAddress,
                (SELECT Id, subscription_Status__c FROM Subscriptions__r),
                (SELECT Id FROM Delivery_Addresses__r)
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Contact getContactByEmail(String email) {
        return [
            SELECT Id, Email, AccountId, Account.Name, Account.BillingAddress,
                (SELECT Id, subscription_Status__c FROM Subscriptions__r),
                (SELECT Id FROM Delivery_Addresses__r)
            FROM Contact
            WHERE Email = :email
            LIMIT 1
        ];
    }

    @AuraEnabled
    public static Contact createDefaultContact(String email) {
        Account subscriberAccount = new Account(Name = 'New Subscriber Household');
        insert subscriberAccount;

        Contact subscriberContact = new Contact(FirstName = 'New', LastName = 'Subscriber', Email = email, AccountId = subscriberAccount.Id);
        insert subscriberContact;

        return subscriberContact;
    }

}