public with sharing class changeAddressController {

    @AuraEnabled
	public static void validateDeliverySchedules(Id subId){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String runningUserProfile = profileList[0].Name;
        if(runningUserProfile == 'CSR') return;
		List<Delivery_Schedule__c> result = [SELECT Id, Frequency_Code__c, Customer_Notes__c, DSI_Id__c,
		Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c,
		End_Date__c, Offer_Product__c, Start_Date__c, 
		Status__c, subscription_Subscription__c, Routelookup__c,
		Delivery_Address__c,  Delivery_Address__r.Address_City__c, Delivery_Address__r.Address_House__c, Delivery_Address__r.Address_Street__c, 
		Delivery_Address__r.Address_Postal_Route__c, Delivery_Address__r.Address_State__c, Offer_Product__r.Product__c
		FROM Delivery_Schedule__c WHERE subscription_Subscription__c = :subId];
		changeAddressController.validateSplitDelivery(result);
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
    public static void updateBillingAddress(Id subId, Map<String, String> address) {
		try{
			Id accId = [SELECT subscription_Account__c FROM Subscription__c WHERE Id = :subId][0].subscription_Account__c;
            Account toUpdate = new Account(
                Id = accId,
                BillingStreet = address.get('street'),
                BillingState = address.get('state'),
                BillingPostalCode = address.get('postalCode'),
                BillingCity = address.get('city')
            );
            update toUpdate;
		}
		catch(Exception e){
			throw new AuraHandledException('Failed To Update Account');
		}	
    }

    @AuraEnabled
    public static String updateDeliveryAddress(Id subId, Id deliveryAddressId, Date effectiveDate) {
        System.debug('deliveryAddressId: ' + deliveryAddressId);
        Date startDate = effectiveDate;
		try{
            List<Delivery_Schedule__c> toUpsert = new List<Delivery_Schedule__c>();
            List<Id> publicationsList = new List<Id>(); 
            Date compareDate = Date.today().addDays(1);
            Date endDate = effectiveDate;
            Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
            if (compareDate == effectiveDate) {
                if(!beforeCutOff){
                    startDate = startDate.addDays(1);
                }
            } else if (effectiveDate < compareDate && (effectiveDate.daysBetween(compareDate) == 1) ) {
                if(beforeCutOff){
                    startDate = startDate.addDays(1);
                } else {
                    startDate = startDate.addDays(2);
                }
            }
            // system.debug('---startDate---' + startDate);
            List<Delivery_Schedule__c> dsList = [
                SELECT Offer_Product__r.Product__c, Id, Customer_Notes__c, DSI_Id__c,
				Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c,
                 Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c,
				Delivery_Address__c, End_Date__c, Offer_Product__c, Start_Date__c, 
				Status__c, subscription_Subscription__c, Routelookup__c
			FROM Delivery_Schedule__c
			WHERE subscription_Subscription__c = :subId AND End_Date__c >= :endDate AND Start_Date__c <= :startDate ];

            for(Delivery_Schedule__c ds : dsList){
                if(!publicationsList.contains(ds.Offer_Product__c)){
                    Delivery_Schedule__c toInsert = new Delivery_Schedule__c(
                        Customer_Notes__c = ds.Customer_Notes__c,
                        Offer_Product__c = ds.Offer_Product__c,
                        Status__c = ds.Status__c,
                        Start_Date__c = startDate, 
                        End_Date__c = ds.End_Date__c,
                        Delivery_Address__c = deliveryAddressId,
                        subscription_Subscription__c = subId
                        );
                        setDeliveryDays(toInsert, dsList);
                        toUpsert.add(toInsert);
                }
                publicationsList.add(ds.Offer_Product__c);
                toUpsert.add(new Delivery_Schedule__c(Id = ds.Id, End_Date__c = startDate.addDays(-1)));
                
            }
              upsert toUpsert; 
        }
		catch(Exception e){
			throw new AuraHandledException('Failed To Update Account');
		}

        // set subscription 'Ready for DSI' flag
        if(subId != null){
            Subscription__c subToUpdate = new Subscription__c(Id = subId, Ready_for_DSI__c = true);
            update subToUpdate;
        }

        return startDate.format();
    }

    private static void setDeliveryDays(Delivery_Schedule__c toInsert, List<Delivery_Schedule__c> dsList){
        Map<String, Boolean> scheduleMap = new Map<String, Boolean>();
        scheduleMap.put('Day_Sunday__c', false);
        scheduleMap.put('Day_Monday__c', false);
        scheduleMap.put('Day_Tuesday__c', false);
        scheduleMap.put('Day_Wednesday__c', false);
        scheduleMap.put('Day_Thursday__c', false);
        scheduleMap.put('Day_Friday__c', false);
        scheduleMap.put('Day_Saturday__c', false);
        for(Delivery_Schedule__c ds : dsList){
            if(ds.Offer_Product__c == toInsert.Offer_Product__c){
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
        }
        toInsert.Day_Sunday__c = scheduleMap.get('Day_Sunday__c');
        toInsert.Day_Monday__c = scheduleMap.get('Day_Monday__c');
        toInsert.Day_Tuesday__c = scheduleMap.get('Day_Tuesday__c');
        toInsert.Day_Wednesday__c = scheduleMap.get('Day_Wednesday__c');
        toInsert.Day_Thursday__c = scheduleMap.get('Day_Thursday__c');
        toInsert.Day_Friday__c = scheduleMap.get('Day_Friday__c');
        toInsert.Day_Saturday__c = scheduleMap.get('Day_Saturday__c');
        
    }

}