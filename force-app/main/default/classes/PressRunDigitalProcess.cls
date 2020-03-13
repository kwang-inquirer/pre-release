global class PressRunDigitalProcess implements Database.Batchable<SObject> {

	global Date pressDay;
	global Boolean activePremium;
	global Boolean activeHoliday;
	global String dayOfWeek;
	

	global PressRunDigitalProcess() {
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
			 dsQuery = 'SELECT Id, Premium_Opt_Out__c, subscription_Offer__c FROM Subscription__c WHERE Premium_Opt_Out__c != TRUE AND subscription_Status__c = \'Active\'';
		}
		else{
			dsQuery = 'SELECT Id, Premium_Opt_Out__c, subscription_Offer__c FROM Subscription__c WHERE subscription_Status__c = \'Active\'';
		}
		return Database.getQueryLocator(dsQuery);
	}

   	global void execute(Database.BatchableContext context, List<Subscription__c> scope) {
		List<Journal__c> journalsToInsert = new List<Journal__c>();
		Decimal rate = 0.0;

        Set<Id> subIds = new Set<Id>();
        for(Subscription__c sub : scope){
            subIds.add(sub.Id);
        }
        
        Map<Id, Offer__c> offersMap = new Map<Id, Offer__c>([SELECT Id, (SELECT Name, Product__c, Per_Copy__c, Per_Copy_Sunday__c FROM Offer_Products__r WHERE Is_Digital__c = TRUE) 
            FROM Offer__c 
            WHERE Id in (SELECT subscription_Offer__c FROM Subscription__c WHERE Id IN :subIds)
        ]);
        
        
		for(Subscription__c sub : scope){
			Offer__c subsOffer;
            Offer_Product__c op;
            if(offersMap != null && offersMap.containsKey(sub.subscription_Offer__c)){
                subsOffer = offersMap.get(sub.subscription_Offer__c);
            }
            else continue;

            if(!subsOffer.Offer_Products__r.isEmpty()){
                op = subsOffer.Offer_Products__r[0];
            }
            else continue;

			rate = dayOfWeek.equals('Sunday') ? op.Per_Copy_Sunday__c : op.Per_Copy__c;

			/* Create Journal Entry Record: Always inserts a Standard Entry Type Journal, except for Holidays.*/
			Journal__c journal = new Journal__c(
				Entry_Type__c = activeHoliday ? 'Holiday' : 'Standard Delivery',
				Entry_Date__c = pressday,
				Debit__c = rate,
				Subscription__c = sub.Id,
				Publication__c = op.Product__c
			);
			journalsToInsert.add(journal);
			if(splitJournals || Test.isRunningTest()){
				journalsToInsert.add(new Journal__c(
				Entry_Type__c = 'Premium Delivery',
				Entry_Date__c = pressday,
				Debit__c = splitRate,
				Subscription__c = sub.Id,
				Publication__c = op.Product__c
				));
			}
		}
		if(!journalsToInsert.isEmpty())
			insert journalsToInsert;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}