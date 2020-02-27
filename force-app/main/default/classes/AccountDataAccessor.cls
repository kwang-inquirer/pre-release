public with sharing class AccountDataAccessor {
    public static Account getAccountById(Id accountId) {
        return [
            SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode, Melissa_Data_Address_Result_Code__c
            FROM Account 
            WHERE Id = :accountId
        ];
    }
}