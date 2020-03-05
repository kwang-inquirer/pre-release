public class AccountTriggerHandler {
    private Map<Id, Account> accounts;
    private Map<Id, Account> oldAccounts;

    public AccountTriggerHandler(Map<Id, Account> accounts, Map<Id, Account> oldAccounts) {
        this.accounts = accounts;
        this.oldAccounts = oldAccounts;
    }

    public void runMelissaDataPersonator() {
        try {
            if (!System.isFuture() && !System.isBatch() && accounts.size() == 1) {
                Account acct = accounts.values()[0];
                if (oldAccounts == null || addressFieldsChanged(acct)) {
                    if (!Test.isRunningTest()) {
                        MDPERSONATOR.MD_PersonatorWSExt.doOnePersonator((String)acct.Id);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    private Boolean addressFieldsChanged(Account acct) {
        Account oldAccount = oldAccounts.get(acct.Id);
        return (acct.BillingStreet != oldAccount.BillingStreet) ||
            (acct.BillingCity != oldAccount.BillingCity) || 
            (acct.BillingState != oldAccount.BillingState) || 
            (acct.BillingPostalCode != oldAccount.BillingPostalCode) || 
            (acct.BillingCountry != oldAccount.BillingCountry);
    }

}