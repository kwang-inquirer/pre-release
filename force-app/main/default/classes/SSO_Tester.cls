@isTest() 
public class SSO_Tester {
    private static testMethod void testSearch() {
        system.debug('**testMethod Start test');
    
        Apex_UserInfo.saveCurrUserSSOInfo('22190', '1234', '41190') ;
        Apex_UserInfo.getCurrUserSSOInfo();
    
    }

}