trigger RecurlyAccountTrigger on recurly_v2__Recurly_Account__c (before insert) {
    List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Recurly_Account_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        RecurlyAccountTriggerHandler handler = new RecurlyAccountTriggerHandler(Trigger.new);
        if (Trigger.isBefore && Trigger.isInsert) {
            handler.onBeforeInsert();
        }
    }
}