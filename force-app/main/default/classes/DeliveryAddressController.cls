public with sharing class DeliveryAddressController {
    @AuraEnabled
    public static List<Delivery_Address__c> getByAddress(Map<String, String> address) {
        return DeliveryAddressDataAccessor.getByFullStreetCityStateZip(address.get('street').toUpperCase(), address.get('city'), address.get('state'), address.get('postalCode'), address.get('unit'));
    }

    @AuraEnabled
    public static Delivery_Address__c getDeliveryAddressById(String deliveryAddressId) {
        return DeliveryAddressDataAccessor.getById(deliveryAddressId);
    }
}