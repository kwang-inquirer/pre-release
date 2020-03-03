public class TransactionDataAccessor {
    public static List<Transaction_Log__c> getLatestComplaintTransactions(Id accountId, Integer count) {
        Id transactionComplaintRecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
        return [
            SELECT Id, Date__c FROM Transaction_Log__c
            WHERE RecordTypeId = :transactionComplaintRecordTypeId
            AND Account__c = :accountId
            ORDER BY Date__c DESC
            LIMIT :count
       ];
    }

    public static Transaction_Log__c getTransaction(Id transactionId) {
        return [
            SELECT Id, Actual_Start__c, Actual_Restart__c
            FROM Transaction_Log__c
            WHERE Id = :transactionId
       ];
    }

    public static Transaction_Type__c getFirstTransactionTypeByCode(String code) {
        return [
            SELECT Id
            FROM Transaction_Type__c
            WHERE Code__c = :code
            LIMIT 1
        ];
    }
}