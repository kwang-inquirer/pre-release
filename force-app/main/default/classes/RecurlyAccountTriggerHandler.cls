public with sharing class RecurlyAccountTriggerHandler {
    private List<recurly_v2__Recurly_Account__c> recurlyAccounts;

    public RecurlyAccountTriggerHandler(List<recurly_v2__Recurly_Account__c> recurlyAccounts) {
        this.recurlyAccounts = recurlyAccounts;
    }

    public void onBeforeInsert() {
        for (recurly_v2__Recurly_Account__c recurlyAccount : recurlyAccounts) {
            if (!isValid(recurlyAccount)) {
                continue;
            }
            String newAccountCode = getNewAccountCode(recurlyAccount);
            if (recurlyAccount.Name == null) {
                recurlyAccount.Name = newAccountCode;
            }
            if (recurlyAccount.recurly_v2__Code__c == null) {
                recurlyAccount.recurly_v2__Code__c = newAccountCode;
            }
        }
    }

    private Boolean isValid(recurly_v2__Recurly_Account__c recurlyAccount) {
        //if (recurlyAccount.Subscription__c == null) {
        //    recurlyAccount.addError('A subscription is required to create a Recurly Account');
        //    return false;
        //}
        //if (recurlyAccount.recurly_v2__Account__c == null) {
        //    recurlyAccount.addError('An account is required to create a Recurly Account');
        //    return false;
        //}
        return true;
    }

    private String getNewAccountCode(recurly_v2__Recurly_Account__c recurlyAccount) {
        String subId = '';
		String accountId = '';
		if(recurlyAccount.Subscription__c != null){subId = String.valueOf(recurlyAccount.Subscription__c).substring(0, 15);}
        if(recurlyAccount.recurly_v2__Account__c != null){accountId = String.valueOf(recurlyAccount.recurly_v2__Account__c).substring(0, 15);}
        return  accountId + '-' + subId + '-' + DateTime.now().format('yyyyMMddHHmmssSSS');
    }
}