@IsTest
public class SubscriptionTriggerHandlerTest {
    @IsTest
    static void testCreateUserAfterSubscription(){
        Account acct = new Account(Name='Test Account');
        insert acct;

        Contact contact = new Contact(FirstName='Test',LastName='Contact', AccountId=acct.Id, Email='ApexTest@inquirer.com');
        insert contact;

        Subscription__c subscription = new Subscription__c(subscription_Account__c=acct.Id);
        subscription.Contact__c = contact.id;
        
        Test.startTest();
        Database.SaveResult result =  Database.insert(subscription, false);
        Test.stopTest();

        System.assert(result.isSuccess());
    }
}