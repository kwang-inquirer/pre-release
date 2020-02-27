trigger TransactionLogTrigger on Transaction_Log__c (before insert,after insert, before update, after update) {
    List<Trigger_Entry__mdt> triggerSwitchList = [
        SELECT DeveloperName, Active__c
        FROM Trigger_Entry__mdt
    ];
    Map<String, Boolean> triggerSwitchMap = new Map<String, Boolean>();
    for(Trigger_Entry__mdt entry : triggerSwitchList){
        triggerSwitchMap.put(entry.DeveloperName, entry.Active__c);
    }
    if(!triggerSwitchList.IsEmpty() && triggerSwitchMap.get('Transaction_Log_Trigger')){
        if( Trigger.isInsert || Trigger.isUpdate){ 
            List<Transaction_Log__c> deliveryTransLogs = new List<Transaction_Log__c>();
            List<Transaction_Log__c> deliveryCreditTransLogs = new List<Transaction_Log__c>();
            List<Transaction_Log__c> vacationTransLogs = new List<Transaction_Log__c>();
            List<Transaction_Log__c> productChangeLogs = new List<Transaction_Log__c>();
            List<Transaction_Log__c> digOptOutTransLogs = new List<Transaction_Log__c>();
            List<Transaction_Log__c> toUpdateExpireInfo = new List<Transaction_Log__c>();

            Set<Id> usedTypes = new Set<Id>();
            Set<Id> subscriptionIds = new Set<Id>();
            //
            // set trans type and related subscriptions
            //
            for(Transaction_Log__c transactionLog : Trigger.new) {
                if (transactionLog.Transaction_Type__c != null) {
                    usedTypes.add(transactionLog.Transaction_Type__c);
                }
                if (transactionLog.Subscription__c != null) {
                    subscriptionIds.add(transactionLog.Subscription__c);
                }
            }
            //
            // Assign transaction to the appropiate bucket
            //

            Map<Id, Transaction_Type__c> pulledTransTypes = new Map<Id, Transaction_Type__c>([SELECT Id, Type_Complaint__c, Apply_Credit_to_Subscription__c, Code__c, Category__c
                        FROM Transaction_Type__c 
                        WHERE Id In: usedTypes]);
            for(Transaction_Log__c tl: trigger.new) {
                Transaction_Type__c thisTT = pulledTransTypes.get(tl.Transaction_Type__c);
                if (tl.Category__c == null) {
                    if(thisTT.Category__c != null){
                        tl.Category__c = thisTT.Category__c;
                    }
                }
                if (thisTT != null) {
                    String complaintType = pulledTransTypes.get(tl.Transaction_Type__c).Type_Complaint__c;
                    String transTypeCode = pulledTransTypes.get(tl.Transaction_Type__c).Code__c;
                    if(thisTT.Apply_Credit_to_Subscription__c == True && tl.Is_Manual__c && Trigger.isBefore) {
                        deliveryCreditTransLogs.add(tl);
                    }
                    else if(thisTT.Apply_Credit_to_Subscription__c == False && tl.Is_Manual__c && Trigger.isBefore){
                        toUpdateExpireInfo.add(tl);
                    }
                    
                    if(pulledTransTypes.get(tl.Transaction_Type__c).Category__c == 'Complaint' 
                                && pulledTransTypes.get(tl.Transaction_Type__c).Code__c != 'SU' 
                                && tl.Is_Manual__c 
                                && Trigger.isAfter 
                                && Trigger.isInsert){
                        deliveryTransLogs.add(tl);
                    }
                    // exclude cancelled vacations from validation
                    if(Trigger.isBefore && tl.Category__c.contains('Vacation') && !tl.Cancelled__c){
                        vacationTransLogs.add(tl);
                    }
                    // product change
                    if(Trigger.isBefore && tl.Category__c.contains('Product Change')){
                        productChangeLogs.add(tl);
                    }
                    // digital opt-out
                    if(Trigger.isAfter && complaintType == 'RETN' && transTypeCode == 'DO'){
                        digOptOutTransLogs.add(tl);
                    }
                }


            }
            //
            // Dispatch transaction
            //
            if(!vacationTransLogs.isEmpty()){
                if(triggerSwitchMap.get('tl_validateExisting'))
                    TransactionLogHandler.validateExisting(vacationTransLogs, subscriptionIds);
                if(triggerSwitchMap.get('tl_setActualDateFields'))
                    TransactionLogHandler.setActualDateFields(vacationTransLogs, subscriptionIds);
            }
            if (productChangeLogs.size() > 0){
                if(triggerSwitchMap.get('tl_setProductChangeDate'))
                    TransactionLogHandler.setProductChangeDate(productChangeLogs, subscriptionIds);
            }
            if (deliveryCreditTransLogs.size() > 0){
                if(triggerSwitchMap.get('tl_ApplyCreditSingleDay'))
                    TransactionLogHandler.ApplyCreditSingleDay(deliveryCreditTransLogs, subscriptionIds);
            }
            if (deliveryTransLogs.size() > 0){
                if(triggerSwitchMap.get('tl_CustomerEscalationCheck'))
                    TransactionLogHandler.CustomerEscalationCheck(deliveryTransLogs);
            }
            if (digOptOutTransLogs.size() > 0){
                if(triggerSwitchMap.get('tl_setDigitalOptOut'))
                    TransactionLogHandler.setDigitalOptOut(digOptOutTransLogs);
            }
            if(toUpdateExpireInfo.size() > 0){
                if(triggerSwitchMap.get('tl_updateExpireInfo'))
                    TransactionLogHandler.updateExpireInfo(toUpdateExpireInfo);
            }
        }
    }
}