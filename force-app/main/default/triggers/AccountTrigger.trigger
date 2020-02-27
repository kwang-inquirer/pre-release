trigger AccountTrigger on Account (after insert, after update) {
        List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Account_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                new AccountTriggerHandler(Trigger.newMap, Trigger.oldMap).runMelissaDataPersonator();
            }
        }
    }
}