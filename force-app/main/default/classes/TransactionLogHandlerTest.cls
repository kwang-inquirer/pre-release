@isTest
public with sharing class TransactionLogHandlerTest {
	@testSetup static void buildDataSet(){
		TestDataFactory.createTestRecords(10);
	}
	@isTest static void shouldCreateComplaint(){
		List<Transaction_Log__c> toInsert = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c];
		List<Offer_Product__c> offerProducts = [SELECT Id FROM Offer_Product__c];
		Transaction_Type__c complaintType = [SELECT Id FROM Transaction_Type__c WHERE Category__c = 'Complaint' LIMIT 1];
		Integer offerProductIndex = 0;
		for(Subscription__c sub : subList){
			toInsert.add(new Transaction_Log__c(
				First_Date__c = System.today(),
       			Last_Date__c = System.today(),
        		Entry_Date__c = System.today(),
       			Transaction_Type__c = complaintType.Id,
				Subscription__c = sub.Id,
				Account__c = sub.subscription_Account__c,
				Offer_Product__c = offerProducts.get(offerProductIndex).Id,
				Category__c = 'Complaint',
				Trouble__c = 'N',
				Message__c = 'Test Complaint'));
			offerProductIndex++;
		}
		insert toInsert;
	}
	@isTest static void shouldCreateCreditComplaint(){
		List<Transaction_Log__c> toInsert = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c];
		List<Offer_Product__c> offerProducts = [SELECT Id FROM Offer_Product__c];
		Transaction_Type__c complaintType = [SELECT Id FROM Transaction_Type__c WHERE Apply_Credit_to_Subscription__c = true LIMIT 1];
		system.debug('--complaintType: '+complaintType);
		Integer offerProductIndex = 0;
		for(Subscription__c sub : subList){
			toInsert.add(new Transaction_Log__c(
				First_Date__c = System.today(),
       			Last_Date__c = System.today(),
        		Entry_Date__c = System.today(),
       			Transaction_Type__c = complaintType.Id,
				Subscription__c = sub.Id,
				Account__c = sub.subscription_Account__c,
				Offer_Product__c = offerProducts.get(offerProductIndex).Id,
				Category__c = 'Complaint',
				Trouble__c = 'N',
				Message__c = 'Test Complaint'));
			offerProductIndex++;
		}
		system.debug('--transLog: ' + toInsert);
		insert toInsert;
	}

	@isTest static void shouldCreateBulkDigitalOptOut(){
		List<Transaction_Log__c> toInsert = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c];
		Transaction_Type__c optOutType = [SELECT Id FROM Transaction_Type__c WHERE Code__c = 'DO' LIMIT 1];
		for(Subscription__c sub : subList){
			toInsert.add(new Transaction_Log__c(
				First_Date__c = System.today(),
        		Entry_Date__c = System.today(),
       			Transaction_Type__c = optOutType.Id,
				Subscription__c = sub.Id));
		}
		insert toInsert;

		subList = [SELECT Id, Digital_Opt_Out__c FROM Subscription__c];
		Boolean stayTrueForDigitalOptOut = true;
		for(Subscription__c sub : subList){
			if(!sub.Digital_Opt_Out__c) 
				stayTrueForDigitalOptOut = false;
		}
		system.assert(stayTrueForDigitalOptOut);
	}

	@isTest static void shouldCreateEscalation(){
		List<Transaction_Log__c> toInsert = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c LIMIT 1];
		Transaction_Type__c optOutType = [SELECT Id FROM Transaction_Type__c WHERE Code__c = 'ND' LIMIT 1];
		for(Subscription__c sub : subList){
			for(Integer i = 0; i < 4; i++){
				toInsert.add(new Transaction_Log__c(
					First_Date__c = System.today().addDays(-i),
					Entry_Date__c = System.today().addDays(-i),
					Transaction_Type__c = optOutType.Id,
					Subscription__c = sub.Id
				));
			}
			
		}
		insert toInsert;
	}

	@isTest static void testsetProductChangeDate() {
		List<Transaction_Log__c> transLogList = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c LIMIT 1];
		Set<Id> subscriptionIds = new Set<Id>();
		for(Subscription__c sub : subList){
			for(Integer i = 0; i < 4; i++){
				transLogList.add(new Transaction_Log__c(
					First_Date__c = System.today().addDays(-i),
					Entry_Date__c = System.today().addDays(-i),
					Subscription__c = sub.Id
				));
			}
			subscriptionIds.add(sub.Id);
		}

		TransactionLogHandler.setProductChangeDate(transLogList,subscriptionIds);
	}

	@isTest static void testSetActualDate() {
		List<Transaction_Log__c> transLogList = new List<Transaction_Log__c>();
		List<Subscription__c> subList = [SELECT Id, subscription_Account__c FROM Subscription__c LIMIT 1];
		Set<Id> subscriptionIds = new Set<Id>();
		for(Subscription__c sub : subList){
			for(Integer i = 0; i < 4; i++){
				transLogList.add(new Transaction_Log__c(
					First_Date__c = System.today().addDays(-i),
					Last_Date__c = System.today().addDays(i),
					Entry_Date__c = System.today().addDays(-i),
					Subscription__c = sub.Id
				));
			}
			subscriptionIds.add(sub.Id);
		}
		//system.debug('--test--transLogList: ' + transLogList);
		//system.debug('--test--subIDs: ' + subscriptionIds);
		TransactionLogHandler.setActualDateFields(transLogList,subscriptionIds);
	}

	@isTest static void testValidateExisting() {
		Transaction_Log__c transLogList  = new Transaction_Log__c();
		Transaction_Log__c transLogList2 = new Transaction_Log__c();
		List<Delivery_Schedule__c> scheduleList = [SELECT Id, subscription_Subscription__c, Start_Date__c, End_Date__c 
					FROM Delivery_Schedule__c
					WHERE Day_Sunday__c = True];
		Transaction_Type__c transType = [SELECT Id FROM Transaction_Type__c WHERE Code__c = 'VH' LIMIT 1];

		system.debug('--test--scheduleList: '+ scheduleList);

		
		transLogList.First_Date__c = System.today().addDays(1);
		transLogList.Last_Date__c = System.today().addDays(7);
		transLogList.Entry_Date__c = System.today();
		transLogList.Transaction_Type__c = transType.Id;
		transLogList.Category__c = 'Vacation Pack';
		transLogList.Cancelled__c = false;
		transLogList.Subscription__c = scheduleList[0].subscription_Subscription__c;
		system.debug('--test--transLogList: ' +transLogList);
		insert transLogList;

		transLogList2.First_Date__c = System.today().addDays(2);
		transLogList2.Last_Date__c = System.today().addDays(9);
		transLogList2.Entry_Date__c = System.today();
		transLogList2.Transaction_Type__c = transType.Id;
		transLogList2.Category__c = 'Vacation Pack';
		transLogList2.Cancelled__c = false;
		transLogList2.Subscription__c = scheduleList[0].subscription_Subscription__c;
		try{
			insert transLogList2;	
		}
		catch (Exception  e){
			System.assert(e.getMessage().contains('A vacation request for this time already exists:'));
		}

		
		
		// TransactionLogHandler.validateExisting(transLogList,subscriptionIds);

		system.debug('--test--done');
	}

}