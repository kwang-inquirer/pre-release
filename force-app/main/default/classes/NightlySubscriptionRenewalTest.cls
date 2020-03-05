@isTest
global class NightlySubscriptionRenewalTest {
    @isTest
    private static void test_schedule() {
        Test.startTest();
            String sch = '0  00 1 3 * ?';
            System.schedule('Nightly Sub Renewal', sch, new NightlySubscriptionRenewalScheduleable());
        Test.stopTest();
    }

    @isTest
    private static void test_batch() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        TestDataFactory.createTestRecords(1);
        Offer__c existingOffer = [SELECT Id FROM Offer__c LIMIT 1];

        List<recurly_v2__Recurly_Account__c> accts = [SELECT Id FROM recurly_v2__Recurly_Account__c];
        Subscription__c sub = [SELECT Id, subscription_Status__c, subscription_Current_Period_Ends_At__c, subscription_Auto_Renew__c, Auto_Renew_Recurly_Account__c FROM Subscription__c LIMIT 1];
        sub.subscription_Status__c = 'Active';
        sub.Pending_Offer__c = existingOffer.Id;
        sub.subscription_Current_Period_Ends_At__c = Date.today();
        sub.subscription_Auto_Renew__c = true;
        sub.Auto_Renew_Recurly_Account__c = accts[0].Id;
        sub.Auto_Renew_Tip__c = 5;
        update sub;

        Test.startTest();
            Database.executeBatch(new NightlySubscriptionRenewalBatch());
        Test.stopTest();

        List<Billing__c> billings = [SELECT Id FROM Billing__c WHERE Subscription__c = :sub.Id];
        System.assertEquals(3, billings.size(), 'There should be 3 billing records created');
    }
}