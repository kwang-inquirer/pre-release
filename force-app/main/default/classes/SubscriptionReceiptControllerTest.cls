@IsTest
global class SubscriptionReceiptControllerTest {
    @IsTest
    private static void test() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', sub.Id);
            SubscriptionReceiptController ctrl = new SubscriptionReceiptController();
        Test.stopTest();

        System.assertEquals(sub.Id, ctrl.sub.Id);
        System.assertEquals(null, ctrl.totalFee);
    }
}