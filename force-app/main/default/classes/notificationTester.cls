@isTest
public class notificationTester {
	@isTest
    static void TestForgotPassword()
    {
        NotificationController.updateCallVar();
        NotificationController.getSessionId();
        NotificationController.getUserId();
        String result=NotificationController.pushCTITopic('param=dwewewrerw');
        
        ctiMsg__c tempMessage = new ctiMsg__c();
        tempMessage.message__c = 'temp';
        tempMessage.Name = 'temp';
        tempMessage.user__c = UserInfo.getUserId();
        insert tempMessage;
        
        result=NotificationController.pushCTITopic('param=dwewewrerw');
        //System.assertEquals(null, result);
    }
}