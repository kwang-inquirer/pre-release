global class PressRunDigitalProcess implements Database.Batchable<SObject> {

	global Date pressDay;
	global String dayOfWeek;
	

	global PressRunDigitalProcess() {
		LastDrawDate__c newDate = LastDrawDate__c.getInstance();
		if(newDate != null) {
			pressDay = newDate.Last_Date__c.addDays(1);
		}
		else {
			pressDay = Date.today();
		}

		/* Cast Date to DateTime to retrieve day of week */
		Datetime processDayDT = (DateTime)pressDay;
		processDayDT = processDayDT.addHours(12);
		dayOfWeek = processDayDT.format('EEEE');
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String dsQuery = '';
		dsQuery = 'SELECT Id, subscription_Offer__c FROM Subscription__c WHERE subscription_Status__c = \'Active\'';
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

			/* Create Journal Entry Record: Always inserts a Standard Entry Type Journal for Digital */
			Journal__c journal = new Journal__c(
				Entry_Type__c = 'Standard Delivery',
				Entry_Date__c = pressday,
				Debit__c = rate,
				Subscription__c = sub.Id,
				Publication__c = op.Product__c
			);
			journalsToInsert.add(journal);
		}
		if(!journalsToInsert.isEmpty())
			insert journalsToInsert;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		LastDrawDate__c newDate = LastDrawDate__c.getInstance();
		if(newDate != null) {
			newDate.Last_Date__c = Date.today();
		}
		else {
			newDate = new LastDrawDate__c(SetupOwnerId=UserInfo.getOrganizationId(), Last_Date__c = Date.today());
		}
		upsert newDate;
	}
}