public with sharing class RecurlyAccountDataAccessor {
    public static List<recurly_v2__Recurly_Account__c> getRecurlyAccountsByAccountId(Id accountId) {
        return [
            SELECT Id, recurly_v2__Code__c
            FROM recurly_v2__Recurly_Account__c
            WHERE recurly_v2__Account__c = :accountId
        ];
    }

    public static List<String> getRecurlyAcctIDsBySubscriptionId(Id subscriptionId){
        List<Subscription__c> subList = [
            SELECT Id, subscription_Account__c, subscription_Status__c, Subscription_Amount__c,
                (SELECT Id  FROM Recurly_Accounts__r)
            FROM Subscription__c
            WHERE Id = :subscriptionId
        ];

        List<String> recurlyAcctIds = new List<String>();
        for(Subscription__c sub : subList){
            for(recurly_v2__Recurly_Account__c ra : sub.Recurly_Accounts__r){
                system.debug('--recurly acct id: ' + ra.Id);
                recurlyAcctIds.add(ra.Id);
            }
        }
        return recurlyAcctIds;
    }
}