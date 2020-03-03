trigger ContactTrigger on Contact (after insert, after update) {
        List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Contact_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                new ContactTriggerHandler(Trigger.newMap, Trigger.oldMap).runMelissaDataPersonator();
            }
        }
    }
}