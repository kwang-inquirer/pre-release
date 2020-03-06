@isTest
private class ChangeAddressControllerTest {
    @isTest static void shouldGetSubscription() {
        Product2 product = new Product2(Name = '175');
        insert product;
        Offer__c offer3 = new Offer__c(Name = 'Offer1');
        insert offer3;

        Product2 digitalProduct = new Product2(Name = '160', IsDigital__c = true);
        insert digitalProduct;
        Offer__c digitalOffer = new Offer__c(Name = 'Offer1');
        insert digitalOffer;

        
        

        Offer_Product__c offerProduct1 = new Offer_Product__c(
            Offer__c = offer3.Id,
            Product__c = product.Id,
            Per_Copy__c = 1.25,
            Per_Copy_Sunday__c = 2.5
        );
        insert offerProduct1;

        Offer_Product__c offerProduct2 = new Offer_Product__c(
            Offer__c = offer3.Id,
            Product__c = product.Id,
            Per_Copy__c = 2.0,
            Per_Copy_Sunday__c = 4.0
        );
        insert offerProduct2;
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

        Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
        Date startDate = Date.today().addDays(-5);
        if(!beforeCutOff){
            startDate = startDate.addDays(1);
        }
        Delivery_Schedule__c ds = new Delivery_Schedule__c();
        ds.subscription_Subscription__c = subscription.Id;
        ds.Delivery_Address__c = toUpdate.Id;
        ds.Offer_Product__c = offerProduct1.Id;
        ds.Start_Date__c = startDate;
        ds.End_Date__c = Date.today().addDays(5);
        
        insert ds;
        
        Id addressId2 = DeliveryAddressDataAccessor.createNewDeliveryAddress(subscription.Id, address);
        Delivery_Address__c toUpdate2 = new Delivery_Address__c(Id = addressId2, Melissa_Response__c = 'AS01');
        update toUpdate2;

        changeAddressController.validateDeliverySchedules(subscription.Id);
        changeAddressController.updateBillingAddress(subscription.Id, address);
        DeliveryAddressDataAccessor.createNewDeliveryAddress(subscription.Id, address);
        addressId = DeliveryAddressDataAccessor.hasValidDeliveryAddress(addressId);
        changeAddressController.updateDeliveryAddress(subscription.Id, addressId, Date.today().addDays(1));
    }

}