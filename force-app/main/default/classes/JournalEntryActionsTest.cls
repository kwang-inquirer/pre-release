@IsTest
global class JournalEntryActionsTest {
    @IsTest
    private static void test_PullJournalEntries() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        insert new List<Journal__c>{
            new Journal__c(Subscription__c = sub.Id)
        };

        Test.startTest();
            List<JournalEntryActions.SuperJournalEntry> journalEntries = JournalEntryActions.PullJournalEntries(sub.Id, null);
            journalEntries[0].compareTo(journalEntries[0]);
        Test.stopTest();

        System.assertEquals(1, journalEntries.size());
    }
}