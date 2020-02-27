trigger OfferTrigger on Offer__c (after insert, after update) {
    List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Offer_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        OfferUtil util = new OfferUtil(trigger.new, trigger.old, trigger.newMap, trigger.oldMap);
        if(trigger.isAfter){
            if(trigger.isInsert){
            }
            else if(trigger.isUpdate){
            }
        }
    }
}