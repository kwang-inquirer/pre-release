@isTest
public with sharing class TransactionLogActionsTest {
    @TestSetup
    private static void generateData(){
        TestDataFactory.createTestRecords(3);
        List<Subscription__c> subs = [SELECT Id, subscription_Account__c FROM Subscription__c];
        List<Transaction_Type__c> transTypes = [SELECT Id from Transaction_Type__c];
        List<Transaction_Log__c> tlsToInsert = new List<Transaction_Log__c>();
        List<Journal__c> journalsToInsert = new List<Journal__c>();
        List<recurly_v2__Recurly_Transaction__c> rTransToInsert = new List<recurly_v2__Recurly_Transaction__c>();
        List<recurly_v2__Recurly_Account__c> rAccsToInsert = new List<recurly_v2__Recurly_Account__c>();
        List<recurly_v2__Recurly_Invoice__c> rInvoicesToInsert = new List<recurly_v2__Recurly_Invoice__c>();
        Case casetoInsert = new Case();
        insert caseToInsert;
        for(Subscription__c sub : subs){
            Transaction_Log__c toInsert = new Transaction_Log__c();
            toInsert.First_Date__c = Date.today();
            toInsert.Last_Date__c = Date.today().addDays(5);
            toInsert.Entry_Date__c = System.today();
            toInsert.Transaction_Type__c = transTypes[0].Id;
            toInsert.Subscription__c = sub.Id;
            toInsert.Account__c = sub.subscription_Account__c;
            toInsert.Case__c = casetoInsert.Id;
            toInsert.Category__c = 'Complaint';
            toInsert.Trouble__c = 'N'; 
            toInsert.Message__c = 'Memo';
            tlsToInsert.add(toInsert);

            Journal__c toInsertJournal = new Journal__c();
            toInsertJournal.Credit__c = 1.0;
            toInsertJournal.Debit__c = 1.0;
            toInsertJournal.Entry_Date__c = Date.today();
            toInsertJournal.Subscription__c = sub.Id;
            journalsToInsert.add(toInsertJournal);
            
           recurly_v2__Recurly_Account__c rAcc = new recurly_v2__Recurly_Account__c();
           rAcc.Subscription__c = sub.Id;
           rAccsToInsert.add(rAcc);

           

        }
        recurly_v2__Recurly_Invoice__c rInvoice = new recurly_v2__Recurly_Invoice__c();
           rInvoice.recurly_v2__Total__c = 10.0;
           rInvoice.recurly_v2__InvoiceID__c = '1';
           rInvoicesToInsert.add(rInvoice);

        insert rInvoicesToInsert;
        insert rAccsToInsert;
        for(recurly_v2__Recurly_Account__c rAccIndex : rAccsToInsert){
            recurly_v2__Recurly_Transaction__c rTrans = new recurly_v2__Recurly_Transaction__c();
            rTrans.recurly_v2__Amount__c = 4.0;
            rTrans.Subscription__c = rAccIndex.Subscription__c;
            rTrans.recurly_v2__Recurly_Account_id__c = rAccIndex.Id;
            rTrans.recurly_v2__Recurly_Invoice__c = rInvoicesToInsert[0].Id;
            rTrans.recurly_v2__Collected_At__c = DateTime.now();
            rTransToInsert.add(rTrans);
           
        }
        
        insert tlsToInsert;
        insert rTransToInsert;
        insert journalsToInsert;
    }
    private static testMethod void shouldGetTransactionLogs() {
        Test.startTest();
       List<Subscription__c> subs = [SELECT Id, subscription_Account__c FROM Subscription__c];
       Case caseInserted = [SELECT Id FROM Case LIMIT 1];
       List<Transaction_Type__c> transTypes = [SELECT Id FROM Transaction_Type__c WHERE Type_Name__c = 'Complaint'];
       
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
            String filterType = 'Message,Vacations,Move/Reroute,Complaints,Product Changes,Financial, Start,Stop,Activity';
            TransactionLogActions.getTransactionLogs(sub.id, filterType);
            TransactionLogActions.getAcctTransactionLogs(sub.subscription_Account__c, 'Complaint');
            TransactionLogActions.getCaseTransactionLogs(caseInserted.Id, 'Complaint');
       }
       Test.stopTest();
    }

    private static testmethod void shouldGetTransactionTypes(){
        Test.startTest();
        List<Account> accs = [SELECT Id FROM Account];
        List<Subscription__c> subs = [SELECT Id FROM Subscription__c];
        TransactionLogActions.getTransactionTypes();
        TransactionLogActions.getTransactionLogs(subs[0].Id, '');
        Test.stopTest();
        
    } 
    private static testmethod void shouldUpdateTransactions(){
         Test.startTest();
          List<Transaction_Log__c> transLogs = [SELECT Id FROM Transaction_Log__c];
        if(!transLogs.isEmpty()){
            TransactionLogActions.CancelTransaction(transLogs[0].Id);
            TransactionLogActions.CancelProductChangeTransaction(transLogs[0].Id);
            TransactionLogActions.CancelTransaction('Throw');
            TransactionLogActions.UpdateTransactionMessage(transLogs[0].Id, 'Test');
            TransactionLogActions.UpdateVacationTransaction((String)transLogs[0].Id, '2020-1-20', '2020-1-25');
            
        }
        Test.stopTest();
           
    }

    private static testmethod void shouldFilterCategory(){
        String result = '';
        result = TransactionLogActions.FilterCategory('Memo');
        result = TransactionLogActions.FilterCategory('Carrier Me');
        result = TransactionLogActions.FilterCategory('Message');
        result = TransactionLogActions.FilterCategory('Vacation Pack');
        result = TransactionLogActions.FilterCategory('VH');
        result = TransactionLogActions.FilterCategory('Move');
        result = TransactionLogActions.FilterCategory('Complaint');
        result = TransactionLogActions.FilterCategory('Product Change');
        result = TransactionLogActions.FilterCategory('Journal');
        result = TransactionLogActions.FilterCategory('Credit_Card');
        result = TransactionLogActions.FilterCategory('CC_Request');
        result = TransactionLogActions.FilterCategory('Start');
        result = TransactionLogActions.FilterCategory('Stop');
        result = TransactionLogActions.FilterCategory('SomethingElse');
    }

}