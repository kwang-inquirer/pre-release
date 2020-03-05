@IsTest
global class RecurlyAccountTriggerTest {
    @IsTest
    private static void test_onBeforeInsert() {
        Account acct = new Account(Name = 'TestAccount');
        insert acct; 

        Subscription__c sub = new Subscription__c(subscription_Account__c = acct.Id);
        insert sub; 

        Test.startTest();
            insert new recurly_v2__Recurly_Account__c(Subscription__c = sub.Id, recurly_v2__Account__c = acct.Id);
        Test.stopTest();

        recurly_v2__Recurly_Account__c recurlyAcct = [SELECT Id, Name, recurly_v2__Code__c FROM recurly_v2__Recurly_Account__c];

        System.assert(true, recurlyAcct.Name.contains(acct.Name));
        System.assert(true, recurlyAcct.Name.contains(sub.Id));
        System.assert(true, recurlyAcct.recurly_v2__Code__c.contains(acct.Name));
        System.assert(true, recurlyAcct.recurly_v2__Code__c.contains(sub.Id));
    }
}