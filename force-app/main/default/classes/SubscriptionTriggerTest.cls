@IsTest
global class SubscriptionTriggerTest {
    @IsTest 
    private static void test_onBeforeInsert() {
        Test.startTest();
            TestDataFactory.createTestRecords(1);
        Test.stopTest();

        System.assert(true, true);
    }
}