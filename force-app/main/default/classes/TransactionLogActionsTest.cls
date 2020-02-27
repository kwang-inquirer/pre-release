@isTest
public with sharing class TransactionLogActionsTest {

    static testMethod void shouldGetTransactionLogs() {
       TestDataFactory.createTestRecords(3);
       List<Subscription__c> subs = [SELECT Id, subscription_Account__c FROM Subscription__c];
       List<Transaction_Type__c> transTypes = [SELECT Id FROM Transaction_Type__c];
       
       for(Subscription__c sub : subs){
            Transaction_Log__c toInsert = new Transaction_Log__c();
            toInsert.First_Date__c = System.today();
            toInsert.Last_Date__c = System.today();
            toInsert.Entry_Date__c = System.today();
            toInsert.Transaction_Type__c = transTypes[0].Id;
            toInsert.Subscription__c = sub.Id;
            toInsert.Account__c = sub.subscription_Account__c;
            toInsert.Category__c = 'Complaint';
            toInsert.Trouble__c = 'N'; 
            toInsert.Message__c = 'TestMemo';
            insert toInsert;
             TransactionLogActions.getTransactionLogs(sub.id, '');
       }
    }

}