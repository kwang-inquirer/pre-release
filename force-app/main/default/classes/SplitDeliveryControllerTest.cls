@isTest
private class SplitDeliveryControllerTest {
    @isTest static void shouldSplitDelivery() {
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

        Id addressId = SplitDeliveryController.createNewDeliveryAddress(subscription.Id, address);
        Delivery_Address__c toUpdate = new Delivery_Address__c(Id = addressId, Melissa_Response__c = 'AS01');
        update toUpdate;

        Delivery_Schedule__c ds = new Delivery_Schedule__c();
        ds.subscription_Subscription__c = subscription.Id;
        ds.Start_Date__c = Date.today().addDays(-10);
        ds.End_Date__c = Date.today().addDays(100);
        
        ds.Delivery_Address__c = toUpdate.Id;
        ds.Day_Sunday__c = true;
        ds.Day_Monday__c = true;
        ds.Day_Tuesday__c = true;
        ds.Day_Wednesday__c = true;
        ds.Day_Friday__c = true;
        ds.Day_Saturday__c = true;
        ds.Day_Thursday__c = true;
        insert ds;
        
        List<Delivery_Schedule__c> dsList = SplitDeliveryController.getDeliverySchedules(subscription.Id);
        Boolean result = SplitDeliveryController.hasValidDeliveryAddress(addressId);
        SplitDeliveryController.rebuildDeliverySchedules(subscription.Id, Date.today().addDays(10), Date.today().addDays(25), addressId, addressId);
    }

}