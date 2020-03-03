@IsTest
global class c1asStreamBrokerControllerTest {
    @IsTest
    private static void test_retrieveSesstionId() {
        Test.startTest();
        String sessionId = c1asStreamBrokerController.retrieveSesstionId();
        Test.stopTest();
        System.assertEquals(UserInfo.getSessionId(), sessionId);
    }

    @IsTest
    private static void test_getUserId() {
        Test.startTest();
        String userId = c1asStreamBrokerController.getUserId();
        Test.stopTest();
        System.assertEquals(UserInfo.getUserId(), userId);
    }
}