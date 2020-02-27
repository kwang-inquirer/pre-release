trigger DeliveryAddressTrigger on Delivery_Address__c (before update, after insert, after update) {
        List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
        WHERE DeveloperName = 'Delivery_Address_Trigger'
    ];
    if(!triggerSwitchList.IsEmpty() && triggerSwitchList[0].Active__c){
        DeliveryAddressTriggerHandler handler = new DeliveryAddressTriggerHandler(Trigger.newMap, Trigger.oldMap);
        if (Trigger.isBefore) {
            if (Trigger.isUpdate) {
                handler.resetMelissaResponseBeforePersonatorExecutes();
                handler.updateAddressAfterPersonatorExecutes();
            }
        }
        if (Trigger.isAfter) {
            if (Trigger.isInsert || Trigger.isUpdate) {
                handler.runMelissaDataPersonator();
            }
        }
    }
}