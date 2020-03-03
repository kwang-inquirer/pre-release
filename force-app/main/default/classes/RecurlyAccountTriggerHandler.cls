public with sharing class RecurlyAccountTriggerHandler {
    private List<recurly_v2__Recurly_Account__c> recurlyAccounts;

    public RecurlyAccountTriggerHandler(List<recurly_v2__Recurly_Account__c> recurlyAccounts) {
        this.recurlyAccounts = recurlyAccounts;
    }

    public void onBeforeInsert() {
        for (recurly_v2__Recurly_Account__c recurlyAccount : recurlyAccounts) {
            if (recurlyAccount.Subscription__c != null && recurlyAccount.recurly_v2__Account__c != null) {
                String newAccountCode = getNewAccountCode(recurlyAccount);
                if (recurlyAccount.Name == null) {
                    recurlyAccount.Name = newAccountCode;
                }
                if (recurlyAccount.recurly_v2__Code__c == null) {
                    recurlyAccount.recurly_v2__Code__c = newAccountCode;
                }
            }
        }
    }

    private String getNewAccountCode(recurly_v2__Recurly_Account__c recurlyAccount) {
        String subId = String.valueOf(recurlyAccount.Subscription__c).substring(0, 15);
        String accountId = String.valueOf(recurlyAccount.recurly_v2__Account__c).substring(0, 15);
        return  accountId + '-' + subId + '-' + DateTime.now().format('yyyyMMddHHmmssSSS');
    }
}