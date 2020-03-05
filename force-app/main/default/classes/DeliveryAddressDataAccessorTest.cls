@isTest
private class DeliveryAddressDataAccessorTest {
    @isTest static void shouldValidateDeliveryAddress() {
        TestDataFactory.createTestRecords(3);
        List<Delivery_Address__c> addressList = [SELECT Id FROM Delivery_Address__c];
        List<Delivery_Schedule__c> scheduleList = [SELECT Id FROM Delivery_Schedule__c];
        Boolean result = DeliveryAddressDataAccessor.hasValidDeliveryAddress(addressList[0].Id);
        List<Delivery_Address__c> resultList = DeliveryAddressDataAccessor.getByScheduleSubId(scheduleList[0].Id);
        List<Delivery_Address__c> resultList2 = DeliveryAddressDataAccessor.getByFullStreetCityStateZip(null, 'Villanova', 'PA', '19132', null);
    }
        @isTest static void shouldDeleteAddress() {
        TestDataFactory.createTestRecords(3);
        List<Delivery_Address__c> addressList = [SELECT Id FROM Delivery_Address__c];
        DeliveryAddressDataAccessor.deleteDeliveryAddress(addressList[0].Id);
    }

    
}