public with sharing class TransactionLogActions {
	
    @AuraEnabled
    public static List<Transaction_Type_Setting__mdt> getTransactionTypes(){

        return [SELECT id, DeveloperName, Color_Value__c, Label FROM Transaction_Type_Setting__mdt where show__c = true ORDER BY Label asc limit 50000];
    }
	@AuraEnabled
	public static String CancelTransaction(String strTransactionId){
		String strResult = '';
		
		try{Transaction_Log__c thisTransaction = new Transaction_Log__c(Id=strTransactionId);
		thisTransaction.Cancelled__c = true;
		
			update thisTransaction;
			strResult = 'success';
		}
		catch (Exception e){
			strResult = e.getMessage();
		}
		return strResult;
	}
	@AuraEnabled
	public static String CancelProductChangeTransaction(String strTransactionId){
		String strResult = '';
		Transaction_Log__c thisTransaction = [SELECT id, subscription__c FROM transaction_log__c WHERE id =: strTransactionId];
		if(thisTransaction != null){
			Subscription__c thisSubscription = new Subscription__c(Id = thisTransaction.Subscription__c);
			thisTransaction.Cancelled__c = true;
			thisSubscription.Pending_Offer__c = null;
			thisSubscription.Pending_Change_Date__c = null;
			try{
				update thisTransaction;
				update thisSubscription;
				strResult = 'success';
			}
			catch (Exception e){
				strResult = e.getMessage();
			}
		}else{
			strResult = 'No Subscription found for Transaction.';
		}
		return strResult;
	}
	@AuraEnabled
	public static String UpdateTransactionMessage(String strTransactionId, String strNewMessage){
		String strResult = '';
		Transaction_Log__c thisTransaction = new Transaction_Log__c(Id=strTransactionId);
		thisTransaction.Message__c = strNewMessage;
		try{
			update thisTransaction;
			strResult = 'success';
		}
		catch (Exception e){
			System.debug('help: ' + e.getMessage());
			if(e.getMessage().contains('No deliveries scheduled for requested Vacation')){
				strResult = 'No deliveries scheduled for requested Vacation';
			}else{
				strResult = e.getMessage();
			}
		}
		return strResult;
	}
	@AuraEnabled
	public static String UpdateVacationTransaction(String strTransactionId, String FirstDate, String LastDate){
		system.debug('--UpdateVacationTransaction-----');
		String strResult = '';
		Transaction_Log__c thisTransaction = new Transaction_Log__c(Id=strTransactionId);
		System.debug('supplied dates: ' + FirstDate + ' - ' + LastDate);

		// Transaction first date cannot be the same date as the current date
		// apply cutoff rule to determine the proper date
		Boolean beforeCutOff = false;		
		system.debug('--today date    : ' + Date.today());
		system.debug('--firstdate date: ' + date.valueOf(FirstDate));

		if(Date.today() == date.valueOf(FirstDate)) {

			// init current date that will be updated based on cutoff rule
			Date calcDate1 = date.valueOf(FirstDate);
			// Date calcDate2 = date.valueOf(LastDate);

			// apply cutoff rule to select proper date
			beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
			if(beforeCutOff){
				calcDate1 = calcDate1.addDays(1);
			}else {
				calcDate1 = calcDate1.addDays(2);
			}
			thisTransaction.First_Date__c = calcDate1;
		} else {
			thisTransaction.First_Date__c = date.valueOf(FirstDate);
		}
		thisTransaction.Last_Date__c = date.valueOf(LastDate);			

		try{
			update thisTransaction;
			strResult = 'success';
		}
		catch (Exception e){
			if(e.getMessage().contains('A vacation request for this time already exists')){
				strResult = 'A vacation request for this time already exists';
			}else if(e.getMessage().contains('No deliveries scheduled for requested Vacation')){
				strResult = 'No deliveries scheduled for requested Vacation';
			}else{
				strResult = e.getMessage();
			}
		}
		return strResult;
	}

    @AuraEnabled
    public static List<SuperTransaction> getTransactionLogs(String sobjId, String filterType){
        System.debug('the type filter is: ' + filterType);
        if(filterType == 'none' || filterType == null || String.isBlank(filterType)) {filterType = '%';}
        // get the type of Id sent
        Schema.SObjectType token = Id.valueOf(sobjId).getSobjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        // Pull the correct logs
        System.debug('the requesting object is: ' + dr.getName());
        List<SuperTransaction> transactionLogs = new List<SuperTransaction>();
        if(dr.getName() == 'Account'){
            transactionLogs = getAcctTransactionLogs(sobjId, filterType);
        }else if(dr.getName() == 'Case'){
            transactionLogs = getCaseTransactionLogs(sobjId, filterType);
        }else if(dr.getName() == 'Subscription__c'){
            transactionLogs = getSubscriptionTransactionLogs(sobjId, filterType);
        }
		transactionLogs.sort();
        return transactionLogs;
    }

	public static List<SuperTransaction> getAcctTransactionLogs(String acctId, String filterType){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Log__c> transactionLogs = new List<Transaction_Log__c>();
        List<string> filterList = filterType.split(',');
		if(filterList.contains('Starts/Stops')){
			filterList.add('Start');
			filterList.add('Stop');
		}
        System.debug('pulling for account: ' + acctId);
        transactionLogs = [SELECT Id, Name, Account__c,Transaction_Type__r.Type_Name__c, Transaction_Type__r.name,
				CreatedBy.Name, CreatedDate, Code_Name__c,
				Description__c, message__c,
				First_Date__c,
				Stop_Date__c,
				Entry_Date__c,
				Memo__c,
				Start_Date__c,
				Last_Date__c, Record_Type_Name__c
			FROM Transaction_Log__c
			WHERE Account__c =: acctId
			AND Transaction_Type__r.Type_Name__c IN: filterList
			ORDER BY CreatedDate DESC
			Limit 1000];	
		For(Transaction_Log__c thisTrans: transactionLogs){
			SuperTransaction thisSt = new SuperTransaction();
			thisSt.Id = thisTrans.Id;
			thisSt.Name = thisTrans.Name;
			thisSt.Account = thisTrans.Account__c;
			thisSt.Transaction_Type_Type_Name = thisTrans.Transaction_Type__r.Type_Name__c;
			thisSt.Transaction_Type_name = thisTrans.Transaction_Type__r.name;
			thisSt.CreatedByName = thisTrans.CreatedBy.Name;
			thisSt.CreatedDate = thisTrans.CreatedDate;
			thisSt.Code_Name = thisTrans.Code_Name__c;
			thisSt.Description = thisTrans.Description__c;
			thisSt.message = thisTrans.message__c;
			thisSt.First_Date = thisTrans.First_Date__c != null ? thisTrans.First_Date__c : thisTrans.CreatedDate.Date();
			thisSt.Stop_Date = thisTrans.Stop_Date__c;
			thisSt.Entry_Date = thisTrans.Entry_Date__c;
			thisSt.Memo = thisTrans.Memo__c;
			thisSt.Start_Date = thisTrans.Start_Date__c;
			thisSt.Last_Date = thisTrans.Last_Date__c;
			thisSt.Record_Type_Name = thisTrans.Record_Type_Name__c;
			lstResult.add(thisSt);
		}
        return lstResult;
    }

	public static List<SuperTransaction> getCaseTransactionLogs(String caseId, String filterType){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Log__c> TransactionLogs = new List<Transaction_Log__c>();
        List<string> filterList = filterType.split(',');
		if(filterList.contains('Starts/Stops')){
			filterList.add('Start');
			filterList.add('Stop');
		}
        System.debug('pulling for case: ' + caseId);
        System.debug('filterList size: ' + filterList);
        transactionLogs = [SELECT Id, Name, Account__c,Transaction_Type__r.Type_Name__c, Transaction_Type__r.name,
				CreatedBy.Name, CreatedDate, Code_Name__c,
				Description__c, message__c,
				First_Date__c,
				Stop_Date__c,
				Entry_Date__c,
				Memo__c,
				Start_Date__c,
				Last_Date__c, Record_Type_Name__c
			FROM Transaction_Log__c
			WHERE Case__c =: caseId
			AND Transaction_Type__r.Type_Name__c IN: filterList
			ORDER BY CreatedDate DESC
			Limit 1000];
        System.debug('total TL pulled case: ' + transactionLogs.size());
        return lstResult;
    }


    public static List<SuperTransaction> getSubscriptionTransactionLogs(String subscriptionId, String filterType){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Log__c> TransactionLogs = new List<Transaction_Log__c>();
        List<string> filterList = filterType.split(',');
		if(filterList.contains('Starts/Stops')){
			filterList.add('Start');
			filterList.add('Stop');
		}
		Map<String, Transaction_Type__c> tTypes = TransactionLogActions.thisTransTypes();
		Map<String, Product2> tProducts = TransactionLogActions.thisProducts();
		// add sObjects
        lstResult.addAll(TransactionLogActions.addTransactionSObjects(subscriptionId,filterList));
        lstResult.addAll(TransactionLogActions.addJournalSObjects(subscriptionId,filterList));
        lstResult.addAll(TransactionLogActions.addRecurlyPaymentSObjects(subscriptionId,filterList));
		// add big objects
		lstResult.addAll(TransactionLogActions.addBOComplaints(subscriptionId, tTypes, filterList, tProducts));
		lstResult.addAll(TransactionLogActions.addBOMemos(subscriptionId, filterList));
		lstResult.addAll(TransactionLogActions.addBOTermination(subscriptionId, filterList));
		lstResult.addAll(TransactionLogActions.addBOVacation(subscriptionId, filterList));
		lstResult.addAll(TransactionLogActions.addBOReroute(subscriptionId, filterList));
        lstResult.addAll(TransactionLogActions.addBOJournalEntries(subscriptionId, filterList));
		lstResult.addAll(TransactionLogActions.addBORecurlyPayments(subscriptionId, filterList));
		// add TransactionComplaint BO
        System.debug('total TL pulled subscription: ' + lstResult.size());
        return lstResult;
    }

	private static  Map<String, Transaction_Type__c> thisTransTypes() {
			Map<String, Transaction_Type__c> mapResult = new Map<String, Transaction_Type__c>();
			List<Transaction_Type__c> tt = new List<Transaction_Type__c>();
			tt = [SELECT
					Code__c,
					Type_Complaint__c,
					Type_Name__c,
					Name
				FROM Transaction_Type__c];
			for(Transaction_Type__c thisT: tt){
				mapResult.put(thisT.Code__c,thisT);
			} 
			return mapResult; 
	}
	private static  Map<String, Product2> thisProducts() {
			Map<String, Product2> mapResult = new Map<String, Product2>();
			List<Product2> tt = new List<Product2>();
			tt = [SELECT
					ProductCode,
					Name
				FROM Product2];
			for(Product2 thisT: tt){
				mapResult.put(thisT.ProductCode,thisT);
			} 
			return mapResult; 
	}
	public static String FilterCategory(String thisCategory){
		String strResult = '';
		// map the given Category to Custom Metadate Type
		if(thisCategory == 'Memo'){
			strResult = 'Message';
		} else if(thisCategory == 'Carrier Me'){
			strResult = 'Message';
		} else if(thisCategory == 'Message'){
			strResult = 'Message';
		} else if(thisCategory == 'Vacation Pack'){
			strResult = 'Vacations';
		} else if(thisCategory == 'VH'){
			strResult = 'Vacations';
		} else if(thisCategory == 'Move'){
			strResult = 'Move/Reroute';
		} else if(thisCategory == 'Complaint'){
			strResult = 'Complaints';
		} else if(thisCategory == 'Product Change'){
			strResult = 'Product Changes';
		} else if(thisCategory == 'Journal'){
			strResult = 'Financial';
		} else if(thisCategory == 'Credit_Card'){
			strResult = 'Financial';			
		} else if(thisCategory == 'CC_Request'){
			strResult = 'Financial';
		} else if(thisCategory == 'Start'){
			strResult = 'Start';
		}else if(thisCategory == 'Stop'){
			strResult = 'Stop';
		} else {
			strResult = 'Activity';
		}

		return strResult;
	}

	private static List<SuperTransaction> addTransactionSObjects(String UseSub, List<string> filterList){
		
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Log__c> pulledTrans = [SELECT Id, Name, Account__c,Transaction_Type__r.Type_Name__c, 
				Transaction_Type__r.name,
				CreatedBy.Name, 
				CreatedDate, 
				Code_Name__c, 
				Category__c,
				Description__c, 
				message__c,
				First_Date__c,
				Stop_Date__c,
				Entry_Date__c,
				Memo__c,
				Start_Date__c,
				Last_Date__c, 
				Record_Type_Name__c, 
				Amount__c,
				Expire_Balance__c,
				Expire_Date__c,
				Offer_Product__r.Product__r.name
			FROM Transaction_Log__c
			WHERE Subscription__c =: UseSub
			AND Cancelled__c = False
			ORDER BY CreatedDate DESC
			Limit 1000];
       

		for(Transaction_Log__c thisTrans: pulledTrans){
            
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.Id;
				thisSt.Name = thisTrans.Name;
				thisSt.Account = thisTrans.Account__c;
				thisSt.Transaction_Type_Type_Name = thisTrans.Transaction_Type__r.Type_Name__c;
				thisSt.Transaction_Type_name = thisTrans.Transaction_Type__r.name;
				thisSt.CreatedByName = thisTrans.CreatedBy.Name;
				thisSt.CreatedDate = thisTrans.CreatedDate;
				thisSt.Code_Name = thisTrans.Code_Name__c;
				thisSt.Description = thisTrans.Description__c;
				thisSt.Message = thisTrans.message__c;
				thisSt.First_Date = thisTrans.First_Date__c != null ? thisTrans.First_Date__c : thisTrans.CreatedDate.Date();
				thisSt.Stop_Date = thisTrans.Stop_Date__c;
				thisSt.Entry_Date = thisTrans.CreatedDate.date();
				thisSt.Memo = thisTrans.Memo__c;
				thisSt.Start_Date = thisTrans.Start_Date__c;
				thisSt.Last_Date = thisTrans.Last_Date__c;
				thisSt.Record_Type_Name = thisTrans.Record_Type_Name__c;
				thisSt.Amount = thisTrans.Amount__c;
				thisSt.Category = TransactionLogActions.FilterCategory(thisTrans.Category__c);
				thisSt.Publication = thisTrans.Offer_Product__r.Product__r.name;
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c; }
				thisSt.isBigObject = false;
				lstResult.add(thisSt);
			}
		}
		return lstResult;
	}
	private static List<SuperTransaction> addBOComplaints(String UseSub, Map<String, Transaction_Type__c> tTypes, List<string> filterList, Map<String, Product2> tProducts){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Complaint__b> pulledTrans = [SELECT 
				Complaint_Code__c,Category__c,
				Delivery_Code__c,
				Description__c,
				Dispatch_Notes__c,
				Entry_Date__c,
				First_Date__c,
				Last_Date__c,
				Message__c,
				Pub__c,
				Redelivery_Requested__c,
				SFID__c,
				Start_Date__c,
				Subscription__c,
				Transaction_Date__c,
				Trans_Number__c,
				Amount__c,
				Trouble__c,
				Type_Name__c,
				Expire_Balance__c,
				Expire_Date__c
			FROM Transaction_Complaint__b
			WHERE Subscription__c =: UseSub
			Limit 1000];
		if(test.isRunningTest()){
			pulledTrans.add(new Transaction_Complaint__b(Subscription__c = UseSub, 
			SFID__c = '123',
			 First_Date__c = DateTime.now(),
			  Entry_Date__c = DateTime.now(), 
			  Start_Date__c = DateTime.now(),
			  Complaint_Code__c = 'DD',
			  Last_Date__c = DateTime.now(),
			  Expire_Balance__c = 0.0,
			  Expire_Date__c = DateTime.now()
			   ));
		}
		for(Transaction_Complaint__b thisTrans: pulledTrans){
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.SFID__c;
				thisSt.Name = thisTrans.Complaint_Code__c;
				thisSt.Transaction_Type_name = thisTrans.Type_Name__c;
				thisSt.Transaction_Type_Type_Name = tTypes.get(thisTrans.Complaint_Code__c).Type_Name__c;
				thisSt.Code_Name = thisTrans.Complaint_Code__c;
				thisSt.Description = thisTrans.Description__c;
				thisSt.Message = thisTrans.Message__c;
				thisSt.First_Date = thisTrans.First_Date__c.Date() != null ? thisTrans.First_Date__c.Date() : thisTrans.CreatedDate.Date();
				thisSt.Stop_Date = thisTrans.Last_Date__c.Date();
				thisSt.Entry_Date = thisTrans.Entry_Date__c.Date();
				thisSt.Start_Date = thisTrans.Start_Date__c.Date();
				thisSt.Last_Date = thisTrans.Last_Date__c.Date();
				thisSt.Amount = thisTrans.Amount__c;
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c.date(); }			
				thisSt.Record_Type_Name = 'Complaint';
				if(tProducts.get(thisTrans.Pub__c) == null){
					thisSt.Publication = 'Alt Pub';
				}else{
					thisSt.Publication = tProducts.get(thisTrans.Pub__c).Name;
				}
				thisSt.Category =TransactionLogActions.FilterCategory(thisTrans.Category__c);
				thisSt.isBigObject = true;
				lstResult.add(thisSt);
			}
		}
		return lstResult;
        //return null;
	}
	
	private static List<SuperTransaction> addBOMemos(String UseSub, List<string> filterList){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Memo__b> pulledTrans = [SELECT
				Account__c,
				Category__c,
				Complaint_Code__c,
				CreatedById,
				CreatedDate,
				Entry_Date__c,
				ID,
				Memo__c,
				SFID__c,
				Subscription__c,
				SystemModstamp,
				Trans_Number__c,
				Type_Name__c,
				Expire_Balance__c,
				Expire_Date__c
			FROM Transaction_Memo__b
			WHERE Subscription__c =: UseSub
			Limit 1000];

			if(test.isRunningTest()){
				pulledTrans.add(new Transaction_Memo__b(Subscription__c = UseSub, 
				SFID__c = '123',
				Entry_Date__c = DateTime.now(), 
				Complaint_Code__c = 'DD',
				Expire_Balance__c = 0.0,
				Expire_Date__c = DateTime.now()
			));
		}
		for(Transaction_Memo__b thisTrans: pulledTrans){
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.SFID__c;
				thisSt.Name = thisTrans.Complaint_Code__c;
				thisSt.Account = thisTrans.Account__c;
				thisSt.Transaction_Type_Type_Name = 'Memo';
				thisSt.Transaction_Type_name = thisTrans.Complaint_Code__c;
				thisSt.First_Date = thisSt.First_Date = thisTrans.Entry_Date__c.Date() != null ? thisTrans.Entry_Date__c.Date() : thisTrans.CreatedDate.Date();
				if(thisTrans.CreatedDate != null) 
					thisSt.Entry_Date = thisTrans.CreatedDate.Date();
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c.date(); }	
				thisSt.Record_Type_Name = 'Memo';
				thisSt.Category =TransactionLogActions.FilterCategory(thisTrans.Category__c);
				thisSt.isBigObject = true;
				lstResult.add(thisSt);
			}
		}
		return lstResult;
	}
	private static List<SuperTransaction> addBOTermination(String UseSub, List<string> filterList){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Termination__b> pulledTrans = [SELECT 
				Account__c,
				Category__c,
				Entry_Date__c,
				Last_Date__c,
				Memo__c,
				Nie_Donate__c,
				SFID__c,
				Start_Date__c,
				Stop_Source__c,
				Subscription__c,
				Term_Code__c,
				Trans_Number__c,
				Type_Name__c,
				Expire_Balance__c,
				Expire_Date__c,
				Created_By_User__c
			FROM Transaction_Termination__b
			WHERE Subscription__c =: UseSub
			Limit 1000];
			
		if(test.isRunningTest()){
			pulledTrans.add(new Transaction_Termination__b(Subscription__c = UseSub, 
			SFID__c = '123',
			  Entry_Date__c = DateTime.now(), 
			  Start_Date__c = DateTime.now(),
			  Expire_Balance__c = 0.0
			   ));
		}
		for(Transaction_Termination__b thisTrans: pulledTrans){
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.SFID__c;
				thisSt.Name = thisTrans.Trans_Number__c;
				thisSt.Transaction_Type_Type_Name = thisTrans.Category__c;
				thisSt.Transaction_Type_name = thisTrans.Term_Code__c;
				thisSt.Code_Name = thisTrans.Term_Code__c;
                thisSt.First_Date = thisTrans.Entry_Date__c.Date() != null ? thisTrans.Entry_Date__c.Date() : thisTrans.CreatedDate.Date();
				thisSt.Entry_Date = thisTrans.Entry_Date__c.Date();
				thisSt.Memo = thisTrans.Memo__c;
				if(thisTrans.Start_Date__c != null){thisSt.Start_Date = thisTrans.Start_Date__c.Date();}
				thisSt.Record_Type_Name = 'Termination';
				thisSt.Account = thisTrans.Account__c;
				thisSt.CreatedByName = thisTrans.Created_By_User__c;
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c.date(); }	
				thisSt.Category = thisTrans.Category__c;
				thisSt.isBigObject = true;
				lstResult.add(thisSt);
			}
		}
		return lstResult;
	}
	private static List<SuperTransaction> addBOReroute(String UseSub, List<string> filterList){
		List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Reroute__b> pulledTrans = [SELECT 
				Category__c,
				Entry_Date__c,
				SFID__c,
				Memo__c,
				Subscription__c,
				Trans_Number__c,
				Type_Name__c,
				Expire_Balance__c,
				Expire_Date__c,
				Term_Code__c,
				Created_By_User__c
			FROM Transaction_Reroute__b
			WHERE Subscription__c =: UseSub
			Limit 1000];
		for(Transaction_Reroute__b thisTrans: pulledTrans){
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.SFID__c;
				thisSt.Name = thisTrans.Trans_Number__c;
				thisSt.Transaction_Type_Type_Name = TransactionLogActions.FilterCategory(thisTrans.Category__c);
				thisSt.Transaction_Type_name = thisTrans.Term_Code__c;
				thisSt.Code_Name = thisTrans.Term_Code__c;
                thisSt.First_Date = thisTrans.Entry_Date__c.Date() != null ? thisTrans.Entry_Date__c.Date() : thisTrans.CreatedDate.Date();
				thisSt.Entry_Date = thisTrans.Entry_Date__c.Date();
				thisSt.Message = thisTrans.Memo__c;
				thisSt.Transaction_Type_name = thisTrans.Category__c;
				thisSt.CreatedByName = thisTrans.Created_By_User__c;
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c.date(); }	
				thisSt.Category =TransactionLogActions.FilterCategory(thisTrans.Category__c);
				thisSt.isBigObject = true;
				lstResult.add(thisSt);
			}
		}
		
		return lstResult;
	}
	private static List<SuperTransaction> addBOVacation(String UseSub, List<string> filterList){
        List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Transaction_Vacation__b> pulledTrans = [SELECT
				Account__c,
				Category__c,
				Created_By_User__c,
				Complaint_Code__c,
				Donation_Type__c,
				Entry_Date__c,
				First_Date__c,
				ID,
				Last_Date__c,
				Memo__c,
				Nie_Donate__c,
				SFID__c,
				Start_Date__c,
				Stop_Source__c,
				Subscription__c,
				Termination_Code__c,
				Trans_Number__c,
				Type_Name__c,
				Expire_Balance__c,
				Expire_Date__c
			FROM Transaction_Vacation__b
			WHERE Subscription__c =: UseSub
			Limit 1000];
		for(Transaction_Vacation__b thisTrans: pulledTrans){
			if(filterList.contains(TransactionLogActions.FilterCategory(thisTrans.Category__c))){
				SuperTransaction thisSt = new SuperTransaction();
				thisSt.Id = thisTrans.SFID__c;
				thisSt.Name = thisTrans.Complaint_Code__c;
				thisSt.Transaction_Type_Type_Name = 'Vacation';
				thisSt.Transaction_Type_name = thisTrans.Complaint_Code__c;
				if(thisTrans.First_Date__c != null){thisSt.First_Date = thisTrans.First_Date__c.Date();}
                else{
                    if(thisTrans.Entry_Date__c != null){
                        thisSt.First_Date = thisTrans.Entry_Date__c.Date();
                    }
                    else{
                        thisSt.First_Date = thisTrans.CreatedDate.Date();
                    }
                    
                }
				if(thisTrans.Last_Date__c != null){thisSt.Stop_Date = thisTrans.Last_Date__c.Date();}
				if(thisTrans.Entry_Date__c != null){thisSt.Entry_Date = thisTrans.Entry_Date__c.Date();}
				if(thisTrans.Memo__c != null){thisSt.Message = thisTrans.Memo__c;}
				if(thisTrans.Start_Date__c != null){thisSt.Start_Date = thisTrans.Start_Date__c.Date();}
				if(thisTrans != null){thisSt.Last_Date = thisTrans.Last_Date__c.Date();}
				thisSt.Record_Type_Name = 'Vacation';
				thisSt.Account = thisTrans.Account__c;
				thisSt.CreatedByName = thisTrans.Created_By_User__c;
				if(thisTrans.Expire_Balance__c != null){ thisSt.Expire_Balance = thisTrans.Expire_Balance__c; }
				if(thisTrans.Expire_Date__c != null){ thisSt.Expire_Date = thisTrans.Expire_Date__c.date(); }	
				thisSt.Category = 'Vacations';
				thisSt.isBigObject = true;
				lstResult.add(thisSt);
			}
		}
		return lstResult;
	}
    private static List<SuperTransaction> addJournalSObjects(Id subId, List<string> FilterList){
        List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Journal__c> pulledJE = [SELECT
                Credit__c,
                Debit__c,
                Description__c,
                Entry_Date__c,
                Entry_Type__c, 
				Created_By_User__c,
				Expire_Balance__c,
				Expire_Date__c
            FROM Journal__c
            WHERE Subscription__c =: subId
            Limit 1000];
        for(Journal__c thisJE: pulledJE){
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory('Journal'))){
				Double thisCredit = thisJE.Credit__c == null? 0.0: thisJE.Credit__c;
				Double thisDebit = thisJE.Debit__c == null? 0.0: thisJE.Debit__c;
				SuperTransaction superJE = new SuperTransaction();
				superJE.Debit = thisJE.Debit__c;
				superJE.Credit = thisJE.Credit__c;
				superJE.Amount = thisCredit - thisDebit;
				superJE.First_Date = thisJE.Entry_Date__c != null ? thisJE.Entry_Date__c : thisJE.CreatedDate.date();
				superJE.Entry_Date = thisJE.Entry_Date__c;
				superJE.EntryType = thisJE.Entry_Type__c;
				superJE.Description = thisJE.Description__c;
				superJE.CreatedByName = thisJE.Created_By_User__c;
				if(thisJE.Expire_Balance__c != null){ superJE.Expire_Balance = thisJE.Expire_Balance__c; }
				if(thisJE.Expire_Date__c != null){ superJE.Expire_Date = thisJE.Expire_Date__c; }
				superJE.Record_Type_Name = 'Journal';
				superJE.Category =TransactionLogActions.FilterCategory('Journal');
				lstResult.add(superJE);
			}
        }
        return lstResult;
    }
    private static List<SuperTransaction> addBOJournalEntries(Id subId, List<string> FilterList){
        List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<Journal_Entry__b> pulledJE = [SELECT
                Credit__c,
                Debit__c,
                Description__c,
                Entry_Date__c,
                Entry_Type__c, 
				Created_By_User__c,
				Expire_Balance__c,
				Expire_Date__c
            FROM Journal_Entry__b
            WHERE Subscription__c =: subId
            Limit 1000];
		if(test.isRunningTest()){
			pulledJE.add(new Journal_Entry__b(
				Credit__c = 1.0,
				Debit__c = 1.0,
				Description__c = 'Test',
				Entry_Date__c = DateTime.now(),
				Entry_Type__c = 'Journal',
				Expire_Date__c = DateTime.now(),
				Expire_Balance__c = 5.0
			));
		}
        for(Journal_Entry__b thisJE: pulledJE){
			if(filterList.contains(TransactionLogActions.FilterCategory('Journal'))){
				Double thisCredit = thisJE.Credit__c == null? 0.0: thisJE.Credit__c;
				Double thisDebit = thisJE.Debit__c == null? 0.0: thisJE.Debit__c;
				SuperTransaction superJE = new SuperTransaction();
				superJE.Debit = thisDebit;
				superJE.Credit = thisCredit;
				superJE.Amount = thisCredit - thisDebit;
				superJE.First_Date = thisJE.Entry_Date__c.date() != null ? thisJE.Entry_Date__c.date() : thisJE.CreatedDate.date();
				superJE.Entry_Date = thisJE.Entry_Date__c.date();
				superJE.EntryType = thisJE.Entry_Type__c;
				superJE.Description = thisJE.Description__c;
				superJE.CreatedByName = thisJE.Created_By_User__c;
				if(thisJE.Expire_Balance__c != null){ superJE.Expire_Balance = thisJE.Expire_Balance__c; }
				if(thisJE.Expire_Date__c != null){ superJE.Expire_Date = thisJE.Expire_Date__c.date(); }
				superJE.Record_Type_Name = 'Journal';
				superJE.Category =TransactionLogActions.FilterCategory('Journal');
				System.debug('this JE: ' + superJE);

				lstResult.add(superJE);
			}
        }
        return lstResult;
    }
    private static List<SuperTransaction> addBORecurlyPayments(Id subId, List<string> filterList){
        List<SuperTransaction> lstResult = new List<SuperTransaction>();
        List<ReCurly_Transaction__b> pulledJE = [SELECT
				Check_Number__c,
				recurly_Amount__c,
				recurly_Collected_At__c,
				recurly_Payment_Card_Type__c,
				recurly_Payment_Last_Four__c, 
				Created_By_User__c,
				Expire_Balance__c,
				Expire_Date__c
			FROM ReCurly_Transaction__b
            WHERE Subscription__c =: subId
            Limit 1000];
        for(ReCurly_Transaction__b thisJE: pulledJE){
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory('Journal'))){
				SuperTransaction superJE = new SuperTransaction();
				if(thisJE.recurly_Amount__c>0){
					superJE.Credit = thisJE.recurly_Amount__c;
				}else{
					superJE.Debit = -thisJE.recurly_Amount__c;				
				}
				superJE.First_Date = thisJE.recurly_Collected_At__c.date() != null ? thisJE.recurly_Collected_At__c.date() : thisJE.CreatedDate.date();
				superJE.Amount = thisJE.recurly_Amount__c;
				superJE.Entry_Date = thisJE.recurly_Collected_At__c.date();
				superJE.EntryType = 'CC Payment';
				superJE.Description = thisJE.recurly_Payment_Card_Type__c;
				superJE.Record_Type_Name = 'Credit Card';
				superJE.Category =TransactionLogActions.FilterCategory('Journal');
				if(thisJE.Expire_Balance__c != null){ superJE.Expire_Balance = thisJE.Expire_Balance__c; }
				if(thisJE.Expire_Date__c != null){ superJE.Expire_Date = thisJE.Expire_Date__c.date(); }
				lstResult.add(superJE);
			}
        }
        return lstResult;
    }

	private static List<SuperTransaction> addRecurlyPaymentSObjects(Id subId, List<string> FilterList){
		List<SuperTransaction> superTransactions = new List<SuperTransaction>();
		/*
        List<recurly_v2__Recurly_Transaction__c> pulledJE = [
			SELECT Check_Number__c, recurly_v2__Amount__c, recurly_v2__Collected_At__c, recurly_v2__Payment_Card_Type__c, recurly_v2__Payment_Last_Four__c, Created_By_User__c, Expire_Balance__c, Expire_Date__c,
				recurly_v2__Recurly_Invoice__c, recurly_v2__Recurly_Invoice__r.recurly_v2__Total__c, recurly_v2__Type__c
			FROM recurly_v2__Recurly_Transaction__c
            WHERE recurly_v2__Recurly_Account_id__c IN (SELECT id 
						FROM recurly_v2__Recurly_Account__c 
						WHERE subscription__c = :subId)
            Limit 1000];
        for(recurly_v2__Recurly_Transaction__c thisJE: pulledJE){
			// set filter criterea
			if(filterList.contains(TransactionLogActions.FilterCategory('Credit_Card'))){
				SuperTransaction superJE = new SuperTransaction();
				if(thisJE.recurly_v2__Amount__c>0){
					superJE.Credit = thisJE.recurly_v2__Amount__c;
				}else{
					superJE.Debit = -thisJE.recurly_v2__Amount__c;				
				}
				superJE.Transaction_Type_name = thisJE.recurly_v2__Type__c;
				superJE.InvoiceId = thisJE.recurly_v2__Recurly_Invoice__c;
				superJE.First_Date = thisJE.recurly_v2__Collected_At__c.date() != null ? thisJE.recurly_v2__Collected_At__c.date() : thisJE.CreatedDate.date();
				superJE.Amount = thisJE.recurly_v2__Recurly_Invoice__r.recurly_v2__Total__c;
				superJE.Entry_Date = thisJE.recurly_v2__Collected_At__c.date();
				superJE.EntryType = 'CC Payment';
				superJE.Description = thisJE.recurly_v2__Payment_Card_Type__c;
				superJE.Record_Type_Name = 'Credit Card';
				superJE.Category =TransactionLogActions.FilterCategory('Credit_Card');
				if(thisJE.Expire_Balance__c != null){ superJE.Expire_Balance = thisJE.Expire_Balance__c; }
				if(thisJE.Expire_Date__c != null){ superJE.Expire_Date = thisJE.Expire_Date__c; }
				superTransactions.add(superJE);
			}
		}
		*/
		List<recurly_v2__Recurly_Invoice__c> invoices = [
			SELECT Id, Name, CreatedDate, recurly_v2__Closed_At__c, recurly_v2__Total__c, recurly_v2__Type__c, recurly_v2__Invoice_Type__c, 
				(SELECT Id, recurly_v2__Amount__c, recurly_v2__State__c, recurly_v2__Line_Item_Description__c FROM recurly_v2__Recurly_Line_Items__r) 
			FROM recurly_v2__Recurly_Invoice__c
			WHERE recurly_v2__Recurly_Account__c IN (SELECT Id FROM recurly_v2__Recurly_Account__c WHERE Subscription__c = :subId)
			LIMIT 1000
		];

		for (recurly_v2__Recurly_Invoice__c invoice : invoices) {
			if(filterList.contains(TransactionLogActions.FilterCategory('Credit_Card'))) {
				SuperTransaction superTrans = new SuperTransaction();
				if(invoice.recurly_v2__Total__c > 0){
					superTrans.Credit = invoice.recurly_v2__Total__c;
				}else{
					superTrans.Debit = -invoice.recurly_v2__Total__c;				
				}

				superTrans.Transaction_Type_name = invoice.recurly_v2__Invoice_Type__c;
				superTrans.InvoiceId = invoice.Id;
				superTrans.First_Date = (invoice.recurly_v2__Closed_At__c != null && invoice.recurly_v2__Closed_At__c.date() != null) ? invoice.recurly_v2__Closed_At__c.date() : invoice.CreatedDate.date();
				superTrans.Amount = invoice.recurly_v2__Total__c;
				superTrans.Entry_Date = (invoice.recurly_v2__Closed_At__c != null && invoice.recurly_v2__Closed_At__c.date() != null) ? invoice.recurly_v2__Closed_At__c.date() : invoice.CreatedDate.date();
				superTrans.EntryType = invoice.recurly_v2__Type__c;
				superTrans.Description = 'Recurly invoice ' + invoice.Name;
				superTrans.Record_Type_Name = 'Credit Card';
				superTrans.Category = TransactionLogActions.FilterCategory('Credit_Card');

				if (invoice.recurly_v2__Recurly_Line_Items__r != null) {
					superTrans.items = new List<SuperTransactionItem>();
					for (recurly_v2__Recurly_Line_Item__c lineItem : invoice.recurly_v2__Recurly_Line_Items__r) {
						superTrans.items.add(new SuperTransactionItem(lineItem.recurly_v2__Amount__c, lineItem.recurly_v2__State__c, lineItem.recurly_v2__Line_Item_Description__c));
					}
				}

				superTransactions.add(superTrans);
			}
		}

        return superTransactions;
	}

	public class SuperTransaction implements Comparable{
		@AuraEnabled public String Id {get;set;} 
		@AuraEnabled public String Name {get;set;}  
		@AuraEnabled public String Account {get;set;} 
		@AuraEnabled public String Transaction_Type_Type_Name {get;set;} 
		@AuraEnabled public String Transaction_Type_name {get;set;} 
		@AuraEnabled public String CreatedByName {get;set;} 
		@AuraEnabled public String InvoiceId {get;set;}
		@AuraEnabled public Datetime CreatedDate {get;set;}  
		@AuraEnabled public String Code_Name {get;set;} 
		@AuraEnabled public String Description {get;set;} 
		@AuraEnabled public String Message {get;set;} 
		@AuraEnabled public Date First_Date {get;set;} 
		@AuraEnabled public Date Stop_Date {get;set;} 
		@AuraEnabled public Date Entry_Date {get;set;} 
		@AuraEnabled public String Memo {get;set;} 
		@AuraEnabled public Date Start_Date {get;set;} 
		@AuraEnabled public Date Last_Date {get;set;} 
		@AuraEnabled public String Record_Type_Name {get;set;} 
		@AuraEnabled public String Publication {get;set;} 
        @AuraEnabled public double Debit {get;set;}
        @AuraEnabled public double Credit {get;set;}
        @AuraEnabled public String EntryType {get;set;}
        @AuraEnabled public String Source {get;set;}
		@AuraEnabled public String Category {get;set;}
        @AuraEnabled public Double Amount {get;set;}
		@AuraEnabled public Double Expire_Balance {get;set;} 
		@AuraEnabled public Date Expire_Date {get;set;} 
		@AuraEnabled public Boolean isBigObject {get;set;}
		@AuraEnabled public List<SuperTransactionItem> items {get;set;}

		public Integer compareTo(Object compareTo){
			Integer intResult = 1;
			SuperTransaction st = (SuperTransaction)compareTo;
			if(First_Date == st.First_Date) return 0;
			if(First_Date > st.First_Date) return -1;
            return 1;
		}
	}

	public class SuperTransactionItem {
		@AuraEnabled public Decimal amount {get;set;}
		@AuraEnabled public String status {get;set;}
		@AuraEnabled public String description {get;set;}

		public SuperTransactionItem(Decimal amount, String status, String description) {
			this.amount = amount;
			this.status = status;
			this.description = description;
		}
	}
}