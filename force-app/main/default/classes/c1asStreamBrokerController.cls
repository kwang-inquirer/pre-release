public with sharing class c1asStreamBrokerController {
	@AuraEnabled
	public static String retrieveSesstionId() {
		return UserInfo.getSessionId();
	}
    
    @AuraEnabled
    public static String getUserId() {
        return UserInfo.getUserId();
    }
}