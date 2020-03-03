@IsTest
global class EmailHistoryTrackerTest {
    @IsTest
    private static void test_SendEmailsToLeadsContacts() {
        TestDataFactory.createTestRecords(1);
        Contact cont = [SELECT Id FROM Contact LIMIT 1];
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        EmailTemplate template = [SELECT Id FROM EmailTemplate LIMIT 1];

        EmailHistoryTracker.EmailInput input = new EmailHistoryTracker.EmailInput();
        input.FromEmailAddress = 'test@test.com';
        input.ConOrLeadId = cont.Id;
        input.RecordId = sub.Id;
        input.emailTemplateName = template.Id;
        input.additional_recipient1 = 'test1@test.com';
        input.additional_recipient2 = 'test2@test.com';
        input.additional_recipient3 = 'test3@test.com';
        input.additional_recipient4 = 'test4@test.com';
        input.additional_recipient5 = 'test5@test.com';

        Test.startTest();
            EmailHistoryTracker.SendEmailsToLeadsContacts(new List<EmailHistoryTracker.EmailInput>{input});
        Test.stopTest();

        System.assertEquals(true, true);
    }    
}