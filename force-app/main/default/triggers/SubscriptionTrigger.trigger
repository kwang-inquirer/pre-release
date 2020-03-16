trigger SubscriptionTrigger on Subscription__c (after insert) {
    List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Subscription_Trigger'
    ];
    
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        SubscriptionTriggerHandler handler = new SubscriptionTriggerHandler(Trigger.newMap, Trigger.oldMap);
        if(Trigger.isAfter) {
            if (Trigger.isInsert) {
                System.debug('Trigger Subscription Insert');
                handler.createUserAfterSubscription();
            }
        }
    }
}