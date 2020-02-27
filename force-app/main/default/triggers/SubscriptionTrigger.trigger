trigger SubscriptionTrigger on Subscription__c (before insert, after insert) {
        List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Subscription_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        SubscriptionTriggerHandler triggerHandler = new SubscriptionTriggerHandler(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        if (Trigger.isBefore && Trigger.isInsert) {
            triggerHandler.onBeforeInsert();
        }
    }
}