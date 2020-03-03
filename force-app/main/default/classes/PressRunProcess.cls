global class PressRunProcess implements Database.Batchable<SObject> {

	global Date pressDay;
	global Boolean activePremium;
	global Boolean activeHoliday;
	global String dayOfWeek;
	

	global PressRunProcess() {
		pressDay = Date.today().addDays(1);
		/* Cast Date to DateTime to retrieve day of week */
		Datetime processDayDT = (DateTime)pressDay;
		processDayDT = processDayDT.addHours(12);
		dayOfWeek = processDayDT.format('EEEE');
		List<Premium_Day__mdt> premiumList = [SELECT Id, Press_Date__c, Type__c FROM Premium_Day__mdt WHERE Press_Date__c = :pressDay];
		activePremium = premiumList.isEmpty() ? false : true;
		activeHoliday = false;
		if(!premiumList.isEmpty()){
			for(Premium_Day__mdt pd : premiumList){
				if(pd.Type__c == 'Holiday')
					activeHoliday = true;
			}
		}
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String dsQuery = '';
		if(activePremium){
			 //TODO: Review this query - Same as the other, but remove check for Day checkbox = true, and check for opt-out.
			 dsQuery = 'SELECT Id, Delivery_Address__c, Delivery_Address__r.Route_Number__c, subscription_Subscription__r.Premium_Opt_Out__c, Offer_Product__r.Product__c, Offer_Product__r.Per_Copy__c, Offer_Product__r.Per_Copy_Sunday__c, subscription_Subscription__c FROM Delivery_Schedule__c WHERE (subscription_Subscription__r.Premium_Opt_Out__c != TRUE AND Day_' + dayOfWeek + '__c = FALSE) AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND subscription_Subscription__r.subscription_Status__c = \'Active\'';
		}
		else{
			dsQuery = 'SELECT Id, Delivery_Address__c, Delivery_Address__r.Route_Number__c, subscription_Subscription__r.Premium_Opt_Out__c, Offer_Product__r.Product__c, Offer_Product__r.Per_Copy__c, Offer_Product__r.Per_Copy_Sunday__c, subscription_Subscription__c FROM Delivery_Schedule__c WHERE Day_' + dayOfWeek + '__c = TRUE AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND subscription_Subscription__r.subscription_Status__c = \'Active\'';
		}
		System.debug(dsQuery);
		return Database.getQueryLocator(dsQuery);
	}

   	global void execute(Database.BatchableContext context, List<Delivery_Schedule__c> scope) {
		List<Journal__c> journalsToInsert = new List<Journal__c>();
		Decimal rate = 0.0;
		Boolean splitJournals = false;
		Decimal splitRate = 0.0;

		for(Delivery_Schedule__c ds : scope){
			
			/* Calculate Adjustments */
			if(activePremium){
				if(ds.subscription_Subscription__r.Premium_Opt_Out__c || activeHoliday){ 
					//UseRate = Offer Product.DailyRate
					rate = ds.Offer_Product__r.Per_Copy__c;
				}
				else{
					rate = ds.Offer_Product__r.Per_Copy__c;
					splitJournals = true;
					splitRate = ds.Offer_Product__r.Per_Copy_Sunday__c - ds.Offer_Product__r.Per_Copy__c;
				}
			}
			else{
				rate = dayOfWeek.equals('Sunday') ? ds.Offer_Product__r.Per_Copy_Sunday__c : ds.Offer_Product__r.Per_Copy__c;
			}

			/* Create Journal Entry Record: Always inserts a Standard Entry Type Journal, except for Holidays.*/
			Journal__c journal = new Journal__c(
				Entry_Type__c = activeHoliday ? 'Holiday' : 'Standard Delivery',
				Entry_Date__c = pressday,
				Debit__c = rate,
				Subscription__c = ds.subscription_Subscription__c,
				Publication__c = ds.Offer_Product__r.Product__c,
				Delivery_Address__c = ds.Delivery_Address__c,
				Route__c = ds.Delivery_Address__r.Route_Number__c
			);
			journalsToInsert.add(journal);
			if(splitJournals){
				journalsToInsert.add(new Journal__c(
				Entry_Type__c = 'Premium Delivery',
				Entry_Date__c = pressday,
				Debit__c = splitRate,
				Subscription__c = ds.subscription_Subscription__c,
				Publication__c = ds.Offer_Product__r.Product__c,
				Delivery_Address__c = ds.Delivery_Address__c,
				Route__c = ds.Delivery_Address__r.Route_Number__c
				));
			}
		}
		if(!journalsToInsert.isEmpty())
			insert journalsToInsert;
	}
	
	global void finish(Database.BatchableContext context) {
		PressRunDigitalProcess b = new PressRunDigitalProcess();
        database.executebatch(b);
	}
}