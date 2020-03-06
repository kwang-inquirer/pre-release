public class SplitDeliveryController  {
	@AuraEnabled
	public static List<Delivery_Schedule__c> getDeliverySchedules(Id subId){
		List<Delivery_Schedule__c> result = [SELECT Id, Frequency_Code__c, Customer_Notes__c, DSI_Id__c,
		Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c,
		End_Date__c, Offer_Product__c, Start_Date__c, 
		Status__c, subscription_Subscription__c, Routelookup__c,
		Delivery_Address__c,  Delivery_Address__r.Address_City__c, Delivery_Address__r.Address_House__c, Delivery_Address__r.Address_Street__c, 
		Delivery_Address__r.Address_Postal_Route__c, Delivery_Address__r.Address_State__c, Offer_Product__r.Product__c
		FROM Delivery_Schedule__c WHERE subscription_Subscription__c = :subId];
		SplitDeliveryController.validateSplitDelivery(result);
		return result;
	}
	
	private static void validateSplitDelivery(List<Delivery_Schedule__c> dsList){
		for(Delivery_Schedule__c item1 : dsList){
			for(Delivery_Schedule__c item2 : dsList)
			if(item1.Start_Date__c <= item2.End_Date__c && 
			item1.End_Date__c >= item2.Start_Date__c && 
			item1.Id != item2.Id && 
			item1.Offer_Product__r.Product__c == item2.Offer_Product__r.Product__c){
				throw new AuraHandledException('A split delivery already exists for this subcription');
			}
		}
	}

    @AuraEnabled
    public static void rebuildDeliverySchedules(Id subId, Date startDate, Date endDate, Id weekdaySelection, Id weekendSelection){
		// init for cutoff rule
		Date currentDate = Date.today();
		Date theDayAfter = Date.today().addDays(1);

		Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
		// apply cutoff rule
		if (currentDate == startDate) {
			if(beforeCutOff){
				startDate = startDate.addDays(1);
			} else {
				startDate = startDate.addDays(2);
			}
		} else if (theDayAfter == startDate){
			if(!beforeCutOff) {
				startDate = startDate.addDays(1);
			}
		}
		//system.debug('--SplitDeliveryController--rebuildDeliverySchedules---');
		//system.debug('--startDate--' + startDate);
		//system.debug('--endDate----' + endDate);

		List<Delivery_Schedule__c> toUpsert = new List<Delivery_Schedule__c>();
		Map<Id, List<Delivery_Schedule__c>> dsByPublication = new Map<Id, List<Delivery_Schedule__c>>();
		List<Delivery_Schedule__c> dsList = [
			SELECT Offer_Product__r.Product__c, Id, Customer_Notes__c, DSI_Id__c,
				Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c,
				Delivery_Address__c, End_Date__c, Offer_Product__c, Start_Date__c, 
				Status__c, subscription_Subscription__c, Routelookup__c
			FROM Delivery_Schedule__c
			WHERE subscription_Subscription__c = :subId AND Day_Monday__c = TRUE AND Day_Tuesday__c = TRUE AND Day_Wednesday__c = TRUE
			AND Day_Thursday__c = TRUE AND Day_Friday__c = TRUE AND Day_Sunday__c = TRUE];
		if(dsList.size() == 0)
			throw new AuraHandledException('No delivery schedules are available to split. A delivery schedule must have both weekday and weekend deliveries.');
		Map<String,Boolean> scheduleMap = new Map<String, Boolean>();
		for(Delivery_Schedule__c ds : dsList){
			if(dsByPublication.get(ds.Offer_Product__r.Product__c) == null){
				dsByPublication.put(ds.Offer_Product__r.Product__c, new List<Delivery_Schedule__c>{ds});
			}
			else{
				List<Delivery_Schedule__c> toUpdate = dsByPublication.get(ds.Offer_Product__r.Product__c);
				toUpdate.add(ds);
				dsByPublication.put(ds.Offer_Product__r.Product__c, toUpdate);
			}
		}
		for(Id pubId : dsByPublication.keySet()){
			scheduleMap.put('Day_Sunday__c', false);
			scheduleMap.put('Day_Monday__c', false);
			scheduleMap.put('Day_Tuesday__c', false);
			scheduleMap.put('Day_Wednesday__c', false);
			scheduleMap.put('Day_Thursday__c', false);
			scheduleMap.put('Day_Friday__c', false);
			scheduleMap.put('Day_Saturday__c', false);

			for(Delivery_Schedule__c ds : dsByPublication.get(pubId)){
				if(ds.Day_Sunday__c)
					scheduleMap.put('Day_Sunday__c', true);
				if(ds.Day_Monday__c)
					scheduleMap.put('Day_Monday__c', true);
				if(ds.Day_Tuesday__c)
					scheduleMap.put('Day_Tuesday__c', true);
				if(ds.Day_Wednesday__c)
					scheduleMap.put('Day_Wednesday__c', true);
				if(ds.Day_Thursday__c)
					scheduleMap.put('Day_Thursday__c', true);
				if(ds.Day_Friday__c)
					scheduleMap.put('Day_Friday__c', true);
				if(ds.Day_Saturday__c)
					scheduleMap.put('Day_Saturday__c', true);
			}
			system.debug('==SplitDelivery: ' + startDate + ' | ' + endDate);

			Delivery_Schedule__c existingDs = dsByPublication.get(pubId)[0];
			Delivery_Schedule__c weekdayDs = new Delivery_Schedule__c(
				Day_Monday__c = scheduleMap.get('Day_Monday__c'),
				Day_Tuesday__c = scheduleMap.get('Day_Tuesday__c'),
				Day_Wednesday__c = scheduleMap.get('Day_Wednesday__c'),
				Day_Thursday__c = scheduleMap.get('Day_Thursday__c'),
				Day_Friday__c = scheduleMap.get('Day_Friday__c'),
				Customer_Notes__c = existingDs.Customer_Notes__c,
				Offer_Product__c = existingDs.Offer_Product__c,
				Status__c = existingDs.Status__c,
				Start_Date__c = startDate, 
				End_Date__c = endDate != null ? endDate : existingDs.End_Date__c,
				Delivery_Address__c = weekdaySelection,
				subscription_Subscription__c = subId
			);
			toUpsert.add(weekdayDs);

			Delivery_Schedule__c weekendDs = new Delivery_Schedule__c(	
				Day_Saturday__c = scheduleMap.get('Day_Saturday__c'),
				Day_Sunday__c = scheduleMap.get('Day_Sunday__c'),
				Customer_Notes__c = existingDs.Customer_Notes__c,
				Offer_Product__c = existingDs.Offer_Product__c,
				Status__c = existingDs.Status__c,
				Start_Date__c = startDate, 
				End_Date__c = endDate != null ? endDate : existingDs.End_Date__c,
				Delivery_Address__c = weekendSelection,
				subscription_Subscription__c = subId	
			);
			toUpsert.add(weekendDs);

			for(Delivery_Schedule__c ds : dsByPublication.get(pubId)){
				if(endDate == null){
					ds.End_Date__c = startDate.addDays(-1);
				}
				else if(ds.End_Date__c > endDate){
					toUpsert.add(new Delivery_Schedule__c(
						Day_Monday__c = ds.Day_Monday__c,
						Day_Tuesday__c = ds.Day_Tuesday__c,
						Day_Wednesday__c = ds.Day_Wednesday__c,
						Day_Thursday__c = ds.Day_Thursday__c,
						Day_Friday__c = ds.Day_Friday__c,
						Day_Saturday__c = ds.Day_Saturday__c,
						Day_Sunday__c = ds.Day_Sunday__c,
						Customer_Notes__c = ds.Customer_Notes__c,
						Offer_Product__c = ds.Offer_Product__c,
						Status__c = ds.Status__c,
						Start_Date__c = endDate.addDays(1), 
						End_Date__c = ds.End_Date__c,
						Delivery_Address__c = ds.Delivery_Address__c,
						subscription_Subscription__c = ds.subscription_Subscription__c
					));
					ds.End_Date__c = startDate.addDays(-1);
				}
				toUpsert.add(ds);
			}
		}
		Subscription__c toUpdate = new Subscription__c(Id = subId, Ready_for_DSI__c = true);
		update toUpdate;
		upsert toUpsert;
    }
}