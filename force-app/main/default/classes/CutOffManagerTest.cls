@isTest 
private class CutOffManagerTest {
	// no asserts are given as the method using Custom Metadata which should not be
	// altered during tests and the logic to know the answer the same as that being tested
	@isTest
	private static void testIsBetween() {
		Boolean testBefore = CutOffManager.isBeforeCutOff('Carrier Memo');
	}
	@isTest
	private static void testListIsBetween() {
		List<String> testRec = new List<String>();
		testRec.add('Carrier Memo');
		List<Boolean> testBefore = CutOffManager.isBeforeCutOff(testRec);
	}
	@isTest
	private static string testDelDayType() {
		String testResult = CutOffManager.DeliveryDayType(Date.today());
		return testResult;
	}
	
	@isTest
	private static void testCommunityDeliveryHelper(){
		 Date currentDate = Date.today();
		 TestDataFactory.createTestRecords(3);
		DateTime transDateDT = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 12, 0, 0);
		List<Transaction_Type__c> transTypeList = [SELECT Id from Transaction_Type__c];
		for(Transaction_Type__c tt : transTypeList){
			CutOffManager.communityDeliveryHelper(tt.Id, currentDate);
		}
		
	}
}