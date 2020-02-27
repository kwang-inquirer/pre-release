public class ShoreMoveController  {
    @AuraEnabled(Cacheable=true)
    public static List<Delivery_Address__c> getDeliveryAddresses(Id subId) {
        return [SELECT Id, Address_City__c, Address_House__c, Address_Street__c, Address_Postal_Route__c, Address_State__c 
		FROM Delivery_Address__c WHERE Id IN (SELECT Delivery_Address__c FROM Delivery_Schedule__c WHERE subscription_Subscription__c = :subId)];
    }

	@AuraEnabled
    public static Id createNewDeliveryAddress(Id subId, Map<String, String> address) {
		try{
			Delivery_Address__c toInsert = new Delivery_Address__c(	
			Address_City__c = address.get('city'),
			Zip__c = address.get('postalCode'),
			Address_State__c = address.get('state'),
			Address_Street__c = address.get('street'));
			insert toInsert;
			return toInsert.Id;
		}
		catch(Exception e){
			System.debug(e);
			return null;
		}
	
		
    }
	@AuraEnabled
	public static Boolean hasValidDeliveryAddress(Id newAddressId) {
		Delivery_Address__c deliveryAddress = [SELECT Melissa_Response__c FROM Delivery_Address__c WHERE Id = :newAddressId LIMIT 1];
        if (String.isEmpty(deliveryAddress.Melissa_Response__c) && !Test.isRunningTest()) {
            throw new GenericException('Melissa response is invalid');
        }
        return deliveryAddress.Melissa_Response__c.contains('AS01');
    }

	@AuraEnabled
	public static void createDeliverySchedule(Id oldAddressId, Id newAddressId, Id subId, Date startDate, Date endDate){
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
		if(subId != null){
			Subscription__c toUpdate = new Subscription__c(Id = subId, Ready_for_DSI__c = true);
			update toUpdate;
		}
	}

}