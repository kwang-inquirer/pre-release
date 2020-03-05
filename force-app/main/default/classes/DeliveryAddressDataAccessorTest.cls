@isTest
private class DeliveryAddressDataAccessorTest {
    @isTest static void shouldValidateDeliveryAddress() {
        TestDataFactory.createTestRecords(3);
        List<Delivery_Address__c> addressList = [SELECT Id FROM Delivery_Address__c];
        List<Delivery_Schedule__c> scheduleList = [SELECT Id FROM Delivery_Schedule__c];
        Id result = DeliveryAddressDataAccessor.hasValidDeliveryAddress(addressList[0].Id);

        List<Delivery_Address__c> resultList = DeliveryAddressDataAccessor.getByScheduleSubId(scheduleList[0].Id);
        List<Delivery_Address__c> resultList2 = DeliveryAddressDataAccessor.getByFullStreetCityStateZip(null, 'Villanova', 'PA', '19132', null);
    }
    @isTest static void shouldDeleteAddress() {
        TestDataFactory.createTestRecords(3);
        List<Delivery_Address__c> addressList = [SELECT Id FROM Delivery_Address__c];
        DeliveryAddressDataAccessor.deleteDeliveryAddress(addressList[0].Id);
    }

    @isTest static void shouldCreateDeliveryAddress(){
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Map<String, String> deliveryMap = new Map<String, String>();
        deliveryMap.put('city', 'Philadelphia');
        deliveryMap.put('postalCode', '19132');
        deliveryMap.put('state', 'PA');
        deliveryMap.put('street', '2032 W Hagert St');
        
        Id addressId = DeliveryAddressDataAccessor.createNewDeliveryAddress(sub.Id, deliveryMap);
        DeliveryAddressDataAccessor.getById(addressId);
    }

    
}