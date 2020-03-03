@isTest
private class SubscriptionDataAccessorTest {
    @isTest static void shouldGetSubscriptionDetails() {
        TestDataFactory.createTestRecords(3);
        List<Subscription__c> subsList = [SELECT Id FROM Subscription__c];
        Subscription__c result = SubscriptionDataAccessor.getSubscription(subsList[0].Id);
        Subscription__c result2 = SubscriptionDataAccessor.getSubscriptionById(subsList[0].Id);
        List<Subscription__c> subs = SubscriptionDataAccessor.getSubscriptionsByEmail('Test@Test.com');
    }
}