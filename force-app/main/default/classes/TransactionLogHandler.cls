/**
* Handler Class for TransactionLogTrigger. Used to update Outstanding Credit and extend expiration date on Subscription with automated Transaction log creation.
*/

public class TransactionLogHandler {
    public static void CustomerEscalationCheck(List<Transaction_Log__c> transLogs){
		System.debug(transLogs);
        List<Transaction_Log__c> newEscalations = new List<Transaction_Log__c>();
        Boolean beforeCutOff = false;       // initialize cutoff flag
        Date currentDate = Date.today();    // init current date that will be updated based on cutoff rule
        Set<Id> subIds = new Set<Id>();
        Set<String> complaintCodes = new Set<String>();
        Set<Id> subscriptionsWithSeriousComplaints = new Set<Id>();
        for(Transaction_Log__c tl : transLogs){
            subIds.add(tl.Subscription__c);
            complaintCodes.add(tl.Complaint_Code__c);
        }

        List<Transaction_Log__c> LogHistory = [SELECT Id, Subscription__c, Complaint_Code__c, CreatedDate
                                                FROM Transaction_Log__c
                                                WHERE Subscription__c IN :subIds];
        List<Customer_Escalation__mdt> ceList = [SELECT Complaint_Code__c, Escalation_Code__c, Occurances__c, Within_Days__c, Message__c 
                  FROM Customer_Escalation__mdt
                  ];
        Map<String, Transaction_Type__c> transTypeMap = new Map<String, Transaction_Type__c>();
        Set<String> escalationCodes = new Set<String>();
        for(Customer_Escalation__mdt ce : ceList){
            escalationCodes.add(ce.Escalation_Code__c);
        }
        for(Transaction_Type__c transType : [SELECT Id, Code__c, Name FROM Transaction_Type__c WHERE Code__c IN :escalationCodes])
            transTypeMap.put(transType.Code__c, transType);
        for(Transaction_Log__c thisLog: transLogs){
            Boolean existingS4 = false;
            for(Transaction_Log__c log : logHistory){
                if(log.Subscription__c == thisLog.Subscription__c && log.Complaint_Code__c == 'S4' && log.CreatedDate > Date.today().addDays(-30))
                    existingS4 = true;
            }
             for(Customer_Escalation__mdt ce : ceList){
                if(ce.Complaint_Code__c.trim().split(',').contains(thisLog.Complaint_Code__c)){
                    Integer useThis = (Integer) ce.Within_Days__c;
                    date datStart = System.today().addDays(-useThis);
					List<String> useComplaints = ce.Complaint_Code__c.trim().split(',');
                    Integer logHistoryCount = 0;

                    for(Transaction_Log__c tl : LogHistory){
                        if(tl.Subscription__c == thisLog.Subscription__c
                            && useComplaints.contains(tl.Complaint_Code__c)
                            && tl.CreatedDate >= datStart)
                            {
                                logHistoryCount++;
                            }
                    }
                    // if needed create escalation transaction
                    if(logHistoryCount >= ce.Occurances__c && !subscriptionsWithSeriousComplaints.contains(thisLog.Subscription__c)){
						if(ce.Escalation_Code__c == 'SU' && !existingS4) continue;
                        if(ce.Escalation_Code__c == 'S4' && existingS4) continue;
                        /*
                        */
                        Id transactionTypeId = null;
                        if(transTypeMap.containsKey(ce.Escalation_Code__c))
                            transactionTypeId = transTypeMap.get(ce.Escalation_Code__c).Id;
                        
                        // apply cutoff rule to select proper date
                        beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
                        if(beforeCutOff){
                            currentDate = currentDate.addDays(1);
                        }else {
                            currentDate = currentDate.addDays(2);
                        }
                        system.debug('==In TransactionLogHandler---CustomerEscalationCheck---');
                        system.debug('==beforeCutOff: ' + beforeCutOff);
                        system.debug('==currentDate:  ' + currentDate);
                         /*   
                        newCELog.Pub__c = thisLog.prod_code__c;
						newCELog.Message__c = ce.Message__c;
						newCELog.Category__c = 'Complaint';
                        newEscalations.add(newCELog);
                        subscriptionsWithSeriousComplaints.add(thisLog.Subscription__c);
                        */
                         Id accountId = [SELECT subscription_Account__c FROM Subscription__c WHERE Id = :thisLog.Subscription__c LIMIT 1].subscription_Account__c;
                        TransactionLogHandler.InsertComplaint(thisLog.Subscription__c, accountId, transactionTypeId, null,  currentDate, null, ce.Message__c);
                    }
                }
            }
        }
        //if(newEscalations.size() > 0){
       //     System.debug('newEscalations.size(): ' + newEscalations.size());
        //    insert newEscalations;
       // }
    }
    

    public static void ApplyCreditSingleDay(List<Transaction_Log__c> transactionLogs, Set<Id> subscriptionIds){
        system.debug('subids '+ subscriptionids);
        system.debug('transLogs--' + transactionLogs);
		// TODO move before new second loop
        Map<Id, Subscription__c> theseSubs = new Map<Id, Subscription__c>([SELECT Id, Money_at_Expire__c, Outstanding_Credit__c FROM Subscription__c WHERE Id IN: subscriptionIds]);

        for(Transaction_Log__c transactionLog : transactionLogs){
            Decimal thisCredit = CreditCalculatorController.calculate(transactionLog.Subscription__c, transactionLog.First_Date__c, transactionLog.First_Date__c, new List<String>{transactionLog.Offer_Product__c});
            system.debug('--ApplyCreditSingleDay: Sub--' + transactionLog.Subscription__c);
            system.debug('--ApplyCreditSingleDay: thisCredit--' + thisCredit);
            Datetime newExpire = CreditCalculatorController.ApplyCreditToSubscription(transactionLog.Subscription__c, thisCredit);
            transactionLog.Amount__c = thisCredit;
            transactionLog.Expire_Date__c = newExpire.date();

			// TODO move in new second loop
            transactionLog.Expire_Balance__c = thisCredit + theseSubs.get(transactionLog.Subscription__c).Money_at_Expire__c;
        }


        //TransactionLogHandler.GetCredit(subscriptionids,system.today(),system.today());
    }

    public static void ApplyCreditSingleDay(List<Journal__c> journals, Set<Id> subscriptionIds){
        Map<Id, Subscription__c> theseSubs = new Map<Id, Subscription__c>([SELECT Id, Outstanding_Credit__c, Number_of_Active_Delivery_Schedules__c, Money_at_Expire__c, subscription_Account__c,Contact__c,
                               subscription_Current_Period_Ends_At__c, subscription_Status__c,
                               (SELECT id, Offer_Product__r.Per_Copy__c, Offer_Product__r.Per_Copy_Sunday__c, Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c, Status__c 
                                FROM Delivery_Schedules__r 
                                WHERE Status__c = 'Active') FROM Subscription__c WHERE Id IN: subscriptionIds]);

        for(Journal__c journal : journals){
            if(journal.Subscription__c != null && theseSubs.containsKey(journal.Subscription__c) && journal.Debit__c != null){
                if(theseSubs.get(journal.Subscription__c).Outstanding_Credit__c != null){
                    theseSubs.get(journal.Subscription__c).Outstanding_Credit__c = theseSubs.get(journal.Subscription__c).Outstanding_Credit__c + journal.Balance__c;
                }
                else{
                     theseSubs.get(journal.Subscription__c).Outstanding_Credit__c = 0.0 + journal.Balance__c;
                }
            }
        }
       CreditCalculatorController.ApplyAdjustment(theseSubs.values());
          
    }
    
    public static void InsertComplaint(Id subscriptionId, Id accountId, Id transactionTypeId, Id offerProductId, Date selectedDate, Boolean requestRedelivery, String memo) {
        Transaction_Log__c toInsert = new Transaction_Log__c();
        toInsert.First_Date__c = selectedDate;
        toInsert.Last_Date__c = selectedDate;
        toInsert.Entry_Date__c = System.today();
        toInsert.Transaction_Type__c = transactionTypeId;
        toInsert.Subscription__c = subscriptionId;
        toInsert.Account__c = accountId;
        // toInsert.Redelivery_Requested__c = requestRedelivery;
        toInsert.Offer_Product__c = offerProductId;
        toInsert.Category__c = 'Complaint';
        toInsert.Trouble__c = 'N'; 
        toInsert.Message__c = memo;
        insert toInsert;
    }


    public static void validateExisting(List<Transaction_Log__c> transactionLogs, Set<id> subscriptionIds){
		// pull the vacation transactions for matching subscriptions
        List<Transaction_Log__c> existingVacations = [SELECT Id, Subscription__c, First_Date__c, Last_Date__c 
					FROM Transaction_Log__c 
					WHERE Subscription__c IN :subscriptionIds 
					AND First_Date__c != null 
					AND Last_Date__c != null 
					AND Cancelled__c = false
					AND Category__c LIKE '%Vacation%'];
		// assign existing to map by subscription
        Map<Id, List<Transaction_Log__c>> subIdToTrans = new Map<Id, List<Transaction_Log__c>>();
        List<Transaction_Log__c> toUpdate = new List<Transaction_Log__c>();
        for(Transaction_Log__c tl : existingVacations){
            if(!subIdToTrans.containsKey(tl.Subscription__c)){
                subIdToTrans.put(tl.Subscription__c, new List<Transaction_Log__c>{tl});
            }
            else{
                toUpdate = subIdToTrans.get(tl.Subscription__c);
                toUpdate.add(tl);
                subIdToTrans.put(tl.Subscription__c, toUpdate);
            }
            System.debug(subIdToTrans);
        }
        // test for overlapping vacations
        for(Transaction_Log__c tl : transactionLogs){
            if(subIdToTrans.containsKey(tl.Subscription__c)){
                if(existingVacation(tl, subIdToTrans.get(tl.Subscription__c))){
                    tl.addError('Vacation requested failed: A vacation request for this time already exists');
                }
            }
        }
    }

    private static boolean existingVacation(Transaction_Log__c tl, List<Transaction_Log__c> existingTrans){

        for(Transaction_Log__c trans : existingTrans){
			if(tl.Id != trans.id){
				if(IsBetween(tl.First_Date__c, trans.First_Date__c, trans.Last_Date__c) || IsBetween(tl.Last_Date__c, trans.First_Date__c, trans.Last_Date__c)){
					return true;
				}
			}
        }
        return false;
    }


    private static boolean IsBetween(DateTime value, DateTime left, DateTime right) {
        return (value >= left && value <= right) || (value <= left && value >= right);
    }

     public static void setDigitalOptOut(List<Transaction_Log__c> transactionLogs){
        Set<Id> subIds = new Set<Id>();
        List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        for(Transaction_Log__c tl : transactionLogs){
            subIds.add(tl.Subscription__c);
        }
        for(Id subId : subIds){
            subsToUpdate.add(new Subscription__c(Id = subId, Digital_Opt_Out__c = true));
        }
        if(subsToUpdate.size() > 0){
            update subsToUpdate;
        }
    }
    
    public static void updateExpireInfo(List<Transaction_Log__c> transactionLogs){
        Set<Id> subscriptionIds = new Set<Id>();
        for(Transaction_Log__c transLog : transactionLogs){
            subscriptionIds.add(transLog.Subscription__c);
        }
        Map<Id, Subscription__c> subscriptionMap = new Map<Id, Subscription__c>([
                SELECT Id, Expires_On__c, Money_at_Expire__c, subscription_Current_Period_Ends_At__c
                FROM Subscription__c
                WHERE Id IN :subscriptionIds
            ]);
        for(Transaction_Log__c transLog : transactionLogs){
			transLog.Expire_Balance__c = subscriptionMap.get(transLog.Subscription__c).Money_at_Expire__c != null ? 
						subscriptionMap.get(transLog.Subscription__c).Money_at_Expire__c : 0.0;
            transLog.Expire_Date__c = subscriptionMap.get(transLog.Subscription__c).subscription_Current_Period_Ends_At__c;
        }
    }

    public static void setProductChangeDate(List<Transaction_Log__c> transactionLogs, Set<Id> subscriptionIds){
        Date effectiveDate = Date.today().addDays(1); // effective date being tomorrow
        Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');

        for(Transaction_Log__c thisTL: transactionLogs){
            // apply the cutoff rule
            if (effectiveDate == thisTL.First_Date__c) {
                if(!beforeCutOff){
                    thisTL.First_Date__c = effectiveDate.addDays(1);
                }
            } else if(thisTL.First_Date__c < effectiveDate ) {
                if(beforeCutOff){
                    thisTL.First_Date__c = effectiveDate;
                } else {
                    thisTL.First_Date__c = effectiveDate.addDays(1);
                }
            }
        }
    }

    public static void setActualDateFields(List<Transaction_Log__c> transactionLogs, Set<id> subscriptionIds){
         Map<Id, Subscription__c> PulledSubscriptions = new Map<Id, Subscription__c>([SELECT id, 
                                 (SELECT id, Start_Date__c, End_Date__c, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c, Day_Wednesday__c, Day_Thursday__c,
                                  Day_Friday__c, Day_Saturday__c, Status__c FROM Delivery_Schedules__r) 
                                 FROM Subscription__c WHERE id IN: subscriptionIds]);
        // system.debug('==PulledSubscriptions: ' + PulledSubscriptions);
        
        // init for cutoff rule
		Date effectiveDate = Date.today().addDays(1); // effective date being tomorrow
        Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');

		for(Transaction_Log__c thisTL: transactionLogs){
			thisTL.Actual_Start__c = null; 
			thisTL.Actual_Restart__c = null;
            // apply the cutoff rule
            if (effectiveDate == thisTL.First_Date__c) {
                if(!beforeCutOff){
                    thisTL.First_Date__c = effectiveDate.addDays(1);
                }
            } else if(thisTL.First_Date__c < effectiveDate ) {
                if(!beforeCutOff){
                    thisTL.First_Date__c = effectiveDate.addDays(1);
                } else {
                    thisTL.First_Date__c = effectiveDate;
                }
            }
            
			Datetime dtStart = DateTime.newInstance(thisTL.First_Date__c, Time.newInstance(0, 0, 0, 0));
			Datetime dtReStart = DateTime.newInstance(thisTL.Last_Date__c, Time.newInstance(0, 0, 0, 0));

            // loop through all the delivery schedules linked to the transaction's subscription
			for(Delivery_Schedule__c thisDS: PulledSubscriptions.get(thisTL.Subscription__c).Delivery_Schedules__r){
				// verify that this is a current delivery schedule
				if(thisDS.Start_Date__c <= thisTL.First_Date__c && thisDS.End_Date__c >= thisTL.Last_Date__c){
					// control variable to prevent error if DS has no days selected
					Integer intWeekLength = 0;
					while (thisTL.Actual_Start__c == null && dtStart <= thisTL.Last_Date__c && intWeekLength<7){				
						if(HasDelivery(thisDS,dtStart.format('EEE'))){
							thisTL.Actual_Start__c = dtStart.date();
						}else{
							dtStart = dtStart.addDays(1);
						}
					}
					intWeekLength = 0;
					while (thisTL.Actual_Restart__c == null && intWeekLength<7){				
						if(HasDelivery(thisDS,dtReStart.format('EEE'))){
							thisTL.Actual_ReStart__c = dtReStart.date();
						}else{
							dtReStart = dtReStart.addDays(1);
						}
					}
				}
			}
			// verify that actual start and end dates are set, else mark the record as in error
			if( (thisTL.Actual_Start__c == null || thisTL.Actual_Restart__c == null) ) {
					thisTL.addError('No deliveries scheduled for requested Vacation');
			}
            // system.debug('==Actual_Start__c: ' + thisTL.Actual_Start__c);
            // system.debug('==Actual_Restart__c: ' + thisTL.Actual_Restart__c);                           
        }
    }

	private static Boolean HasDelivery(Delivery_Schedule__c ds, String dayOfWeek){
		Boolean booResult = false;
        if(ds.Day_Sunday__c && dayOfWeek == 'Sun')
        {
			return true;
        }
        if(ds.Day_Monday__c && dayOfWeek == 'Mon')
        {
			return true;
        }
        if(ds.Day_Tuesday__c && dayOfWeek == 'Tue')
        {
			return true;
        }
        if(ds.Day_Wednesday__c && dayOfWeek == 'Wed')
        {
			return true;
        }
        if(ds.Day_Thursday__c && dayOfWeek == 'Thu')
        {
			return true;
        }
        if(ds.Day_Friday__c && dayOfWeek == 'Fri')
        {
			return true;
        }
        if(ds.Day_Saturday__c && dayOfWeek == 'Sat')
        {
			return true;
        }
		return booResult;
	}
}