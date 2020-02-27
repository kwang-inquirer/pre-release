@isTest
private class ShoreMoveControllerTest {
    @isTest static void shouldGetSubscription() {
        Account account = new Account(
            Name = 'RelationEdge');
        insert account;
        Offer__c offer = new Offer__c();
        offer.Name = 'TestOffer';
        insert offer;
        Contact contact = new Contact(FirstName = 'Relation', LastName = 'Edge', Email='Test@Test.com');
        insert contact;
        Subscription__c subscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdge',
            Delivery_Instructions__c = 'Throw it at the front door.',
            Outstanding_Credit__c = 20.25,
            subscription_Offer__c = offer.Id,
            contact__c = contact.Id
            );
        insert subscription;
        Map<String, String> address = new Map<String, String>();
        address.put('city', 'Villanova');
        address.put('postalCode', '19132');
        address.put('state', 'PA');
        address.put('street', '2030 W Hagert St');

        Id addressId = DeliveryAddressDataAccessor.createNewDeliveryAddress(subscription.Id, address);
        Delivery_Address__c toUpdate = new Delivery_Address__c(Id = addressId, Melissa_Response__c = 'AS01');
        update toUpdate;

        Delivery_Schedule__c ds = new Delivery_Schedule__c();
        ds.subscription_Subscription__c = subscription.Id;
        ds.Delivery_Address__c = toUpdate.Id;
        insert ds;
        
        Id addressId2 = DeliveryAddressDataAccessor.createNewDeliveryAddress(subscription.Id, address);
        Delivery_Address__c toUpdate2 = new Delivery_Address__c(Id = addressId2, Melissa_Response__c = 'AS01');
        update toUpdate2;

        DeliveryAddressDataAccessor.getDeliveryAddresses(subscription.Id);
        DeliveryAddressDataAccessor.hasValidDeliveryAddress(addressId);
        ShoreMoveController.createDeliverySchedule(addressId, addressId2, subscription.Id, Date.today(), Date.today().addDays(2));
    }

}