@IsTest
global class RecentSalesControllerTest {
    @IsTest
    private static void test() {
        TestDataFactory.createTestRecords(1);

        Test.startTest();
            RecentSalesController ctrl = new RecentSalesController();
        Test.stopTest();

        System.assertEquals(1, ctrl.subs.size());
        System.assertEquals(UserInfo.getUserId(), ctrl.currentUser);
    }
}