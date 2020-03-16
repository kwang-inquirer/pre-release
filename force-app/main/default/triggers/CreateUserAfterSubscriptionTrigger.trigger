trigger CreateUserAfterSubscriptionTrigger on Subscription__c (after insert) {
    Profile communityUserProfile = [SELECT Id FROM Profile WHERE Name='Subscriber Community' Limit 1];
    List<User> newUsers = new List<User>();
    
    Set<ID> contactIds = new Set<ID>();
    for(Subscription__c sub : Trigger.New) {
        if(sub.Contact__c != null) {
            contactIds.add(sub.Contact__c);
        }
    }
    
    Map<ID, Contact> contacts = new Map<ID, Contact>([
        SELECT ID, FirstName, LastName, Email
        FROM Contact
        WHERE ID in :contactIds
    ]);
    
    for(Subscription__c sub : Trigger.New) {
        Contact subContact = contacts.get(sub.Contact__c);
        User newUser = new User(
            UserName = subContact.Email,
            FirstName = subContact.FirstName,
            LastName = subContact.LastName,
            Alias = subContact.FirstName,
            Email = subContact.Email,
            ContactId = sub.Contact__c,
            ProfileId = communityUserProfile.Id,
            EmailEncodingKey = 'UTF-8',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
		);
        newUsers.add(newUser);
    }   
    System.debug(newUsers);
    Database.insert(newUsers);
}