@IsTest
global class DeliveryAddressTriggerTest {
    @IsTest
    private static void test() {
        TestDataFactory.createTestRecords(1);
        Delivery_Address__c address = [SELECT Id, Address_Street__c FROM Delivery_Address__c LIMIT 1];

        insert new MDPERSONATOR__MD_personatorResult__c(
            MDPERSONATOR__RecordID__c = address.Id,
            MDPERSONATOR__AddressHouseNumber__c = '1234',
            MDPERSONATOR__AddressPreDirection__c = 'W',
            MDPERSONATOR__AddressPostDirection__c = '',
            MDPERSONATOR__AddressStreetName__c = 'Test',
            MDPERSONATOR__AddressStreetSuffix__c = 'Rd',
            MDPERSONATOR__AddressLine1__c = '',
            MDPERSONATOR__City__c = 'Test City',
            MDPERSONATOR__State__c = 'CA',
            MDPERSONATOR__PostalCode__c = '12345'
        );

        Route__c route = new Route__c();
        insert route;
        
        insert new Route_Street__c(House_Low__c = 1, House_High__c = 9999, Street_Name__c = 'Test', ZIP__c = '12345', Route__c = route.Id);

        Test.setMock(HttpCalloutMock.class, new MelissaDataPersonatorMock());

        Test.startTest();
            address.Address_Street__c = '1234 Test Rd';
            update address;

            updateAddressFuture(address.Id);
        Test.stopTest();
    }

    @future
    private static void updateAddressFuture(Id addressId) {
        Delivery_Address__c address = [SELECT Id FROM Delivery_Address__c WHERE Id = :addressId];
        update address;
    }
}