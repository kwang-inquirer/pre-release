public class ShoreMoveController  {

	@AuraEnabled
	public static String createDeliverySchedule(Id oldAddressId, Id newAddressId, Id subId, Date startDate, Date endDate){
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

		List<Delivery_Schedule__c> toUpsert = new List<Delivery_Schedule__c>();
		List<Delivery_Schedule__c> oldDeliveryScheduleList = [SELECT Id, Customer_Notes__c, DSI_Id__c,
		Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c,
		Delivery_Address__c, End_Date__c, Offer_Product__c, Start_Date__c, 
		Status__c, subscription_Subscription__c, Routelookup__c
		FROM Delivery_Schedule__c WHERE Delivery_Address__c = :oldAddressId
		AND subscription_Subscription__c = :subId];
		for(Delivery_Schedule__c oldDeliverySchedule : oldDeliveryScheduleList){

			Delivery_Schedule__c toInsert = new Delivery_Schedule__c(
				Customer_Notes__c = oldDeliverySchedule.Customer_Notes__c,
				Routelookup__c =  oldDeliverySchedule.Routelookup__c,
				DSI_Id__c = oldDeliverySchedule.DSI_Id__c,
				Day_Friday__c = oldDeliverySchedule.Day_Friday__c,
				Day_Monday__c = oldDeliverySchedule.Day_Monday__c,
				Day_Saturday__c = oldDeliverySchedule.Day_Saturday__c,
				Day_Sunday__c = oldDeliverySchedule.Day_Sunday__c,
				Day_Thursday__c = oldDeliverySchedule.Day_Thursday__c,
				Day_Tuesday__c = oldDeliverySchedule.Day_Tuesday__c, 
				Day_Wednesday__c = oldDeliverySchedule.Day_Wednesday__c,
				Delivery_Address__c = newAddressId,
				End_Date__c = endDate,
				Offer_Product__c = oldDeliverySchedule.Offer_Product__c,
				Start_Date__c = startDate,
				Status__c = oldDeliverySchedule.Status__c,
				subscription_Subscription__c = oldDeliverySchedule.subscription_Subscription__c
			);
			toUpsert.add(toInsert);
			oldDeliverySchedule.End_Date__c = startDate.addDays(-1);
			toUpsert.add(oldDeliverySchedule);
		}
		if(!toUpsert.isEmpty()){
			upsert toUpsert;
		}
		
		return startDate.format();
	}

}