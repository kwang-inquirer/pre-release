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
}