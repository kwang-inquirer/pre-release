trigger JournalTrigger on Journal__c (before insert) {
    List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Journal_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        if( Trigger.isInsert || Trigger.isUpdate){
            List<Journal__c> journalsToApplyCredit = new List<Journal__c>();
            Set<Id> subscriptionIds = new Set<Id>();    
            for(Journal__c jrn: trigger.new) {
                if(Trigger.isBefore) {
                    journalsToApplyCredit.add(jrn);
                    subscriptionIds.add(jrn.Subscription__c);
                }
            }
            if (journalsToApplyCredit.size() > 0){
                TransactionLogHandler.ApplyCreditSingleDay(journalsToApplyCredit, subscriptionIds);
            }
        }
    }
}