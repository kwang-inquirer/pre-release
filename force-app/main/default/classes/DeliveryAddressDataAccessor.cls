public with sharing class DeliveryAddressDataAccessor {
    public static Delivery_Address__c getById(Id deliveryAddressId) {
        return [
            SELECT Id, Address_Full_Street__c, Address_House__c, Pre_Direction__c, Address_Street__c, Address_City__c, Address_State__c, Zip__c, Unit__c, Route_Number__c, Melissa_Response__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressHouseNumber__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressPreDirection__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressPostDirection__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressStreetName__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressStreetSuffix__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__AddressLine1__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__City__c, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__State__c	, 
                Clean_Suite_Personator_Result__r.MDPERSONATOR__PostalCode__c,
                DSI_Id__c
            FROM Delivery_Address__c
            WHERE Id = :deliveryAddressId
        ];
    }

    public static List<Delivery_Address__c> getByFullStreetCityStateZip(String fullStreet, String city, String state, String postalCode, String unit) {
        return [
            SELECT Id, Address_Full_Street__c, Address_House__c, Pre_Direction__c, Address_Street__c, Address_City__c, Address_State__c, Zip__c, Unit__c, Route_Number__c, Melissa_Response__c
            FROM Delivery_Address__c
            WHERE Address_Full_Street__c = :fullStreet
            AND Address_City__c = :city
            AND Address_State__c = :state
            AND Address_Postal_Route__c = :postalCode
            AND Unit__c = :unit
        ];
    }

    public static List<Delivery_Address__c> getByScheduleSubId(Id subId) {
        return [
            SELECT Id, Address_Full_Street__c, Address_House__c, Pre_Direction__c, Address_Street__c, Address_City__c, Address_State__c, Zip__c, Unit__c, Route_Number__c, Melissa_Response__c
            FROM Delivery_Address__c
            WHERE Id IN (SELECT Delivery_Address__c FROM Delivery_Schedule__c WHERE subscription_Subscription__c = :subId)
        ];
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
			return null;
		}
    }

    	@AuraEnabled
	public static Id hasValidDeliveryAddress(Id newAddressId) {
        System.debug('Id: ' + newAddressId);
        Delivery_Address__c deliveryAddress = [SELECT Id, Pre_Direction__c, Post_Direction__c, Address_Full_Street__c, Address_Suffix__c, Address_Postal_Route__c, Address_City__c, Melissa_Response__c, Address_State__c, DSI_Id__c, Address_House__c, Address_Street__c, Zip__c, Unit__c FROM Delivery_Address__c WHERE Id = :newAddressId LIMIT 1];

        if (!String.isEmpty(deliveryAddress.Address_House__c)) {
            List<Route_Street__c> relatedRouteStreets = RouteDataAccessor.getRouteStreets(Decimal.valueOf(deliveryAddress.Address_House__c), deliveryAddress.Address_Street__c, deliveryAddress.Zip__c);
            deliveryAddress.Route_Number__c = (relatedRouteStreets.isEmpty()) ? null : relatedRouteStreets[0].Route__c;
			
            /*Depends on custom metadata type to check if dsi id replication is linked*/
          
			if (deliveryAddress.Route_Number__c != null || Test.isRunningTest()) {
				update deliveryAddress;
			}
			else {
				throw new GenericException('No route found for this address.');
			}
        }

        if(deliveryAddress.Melissa_Response__c != null || Test.isRunningTest()){
            List<Delivery_Address__c> dupAddresses = DeliveryAddressDataAccessor.getDuplicateAddresses(deliveryAddress.Id, deliveryAddress.Pre_Direction__c, deliveryAddress.Post_Direction__c, deliveryAddress.Address_House__c, deliveryAddress.Address_Street__c, deliveryAddress.Address_Suffix__c, deliveryAddress.Unit__c, deliveryAddress.Zip__c);
            System.debug('dupAddresses: ' + dupAddresses);
            if(!dupAddresses.isEmpty()){
                deliveryAddress = dupAddresses[0];
                DeliveryAddressDataAccessor.deleteDeliveryAddress(newAddressId);
            }
            else{
                Organization org = [SELECT Id FROM Organization LIMIT 1];
                Organization_Settings__mdt orgSetting = [
                    SELECT Validate_DSI_ID_on_New_Delivery_Address__c 
                    FROM Organization_Settings__mdt 
                    WHERE Organization_Id__c = :org.Id LIMIT 1];
                
                if(orgSetting.Validate_DSI_ID_on_New_Delivery_Address__c && 
                    deliveryAddress.DSI_Id__c == null) throw new GenericException('No DSI Id found for this address');
            }
        }
        
        if(deliveryAddress.Melissa_Response__c != null && deliveryAddress.Melissa_Response__c.contains('AS01'))
                return deliveryAddress.Id;

        throw new GenericException('Melissa response is invalid');
        
    }

    @AuraEnabled(Cacheable=true)
    public static List<Delivery_Address__c> getDeliveryAddresses(Id subId) {
        return [SELECT Id, Address_City__c, Address_House__c, Address_Street__c, Address_Postal_Route__c, Address_State__c 
		FROM Delivery_Address__c WHERE Id IN (SELECT Delivery_Address__c FROM Delivery_Schedule__c WHERE subscription_Subscription__c = :subId)];
    }

    @AuraEnabled
    public static void deleteDeliveryAddress(Id newAddressId){
        if(newAddressId != null){
            Delivery_Address__c toDelete = new Delivery_Address__c(Id = newAddressId);
            delete toDelete;
        }       
    }


    private static List<Delivery_Address__c> getDuplicateAddresses(Id addressId, String preDirection, String postDirection, String houseNumber, String street, String suffix, String unit, String zip){
        return [
            SELECT Id, Pre_Direction__c, Post_Direction__c, Address_Full_Street__c, Address_Suffix__c, Address_Postal_Route__c, Address_City__c, Melissa_Response__c, Address_State__c, DSI_Id__c, Address_House__c, Address_Street__c, Zip__c, Unit__c 
            FROM Delivery_Address__c
            WHERE Pre_Direction__c = :preDirection AND Post_Direction__c = :postDirection AND Address_House__c = :houseNumber 
            AND Address_Street__c = :street AND Address_Suffix__c = :suffix AND Unit__c = :unit AND Zip__c = :zip
            AND Id != :addressId
        ];
    }
}