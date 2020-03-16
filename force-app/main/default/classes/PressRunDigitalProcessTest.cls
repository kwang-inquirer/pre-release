@isTest
private class PressRunDigitalProcessTest {
    @testSetup 
    static void setup() {

         Account account = new Account(
            Name = 'Digital Account Test 1');
        insert account;
        
        Product2 digitalProduct = new Product2(Name = '160', IsDigital__c = true);
        insert digitalProduct;
        Offer__c digitalOffer = new Offer__c(Name = 'All Digital');
        insert digitalOffer;

        Offer_Product__c digitalOfferProduct = new Offer_Product__c(
            Offer__c = digitalOffer.Id,
            Product__c = digitalProduct.Id,
            Per_Copy__c = 0.25,
            Per_Copy_Sunday__c = 0.25
        );
        insert digitalOfferProduct;

        Subscription__c digitalSubscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'Digital Sub',
            Delivery_Instructions__c = 'N/A',
            Outstanding_Credit__c = 20.00,
            subscription_Status__c = 'Active',
            subscription_Offer__c = digitalOffer.Id
        );
        insert digitalSubscription;

        LastDrawDate__c newDate = new LastDrawDate__c(Last_Date__c = Date.today().addDays(-2));
		insert newDate;
        
    }
    static testmethod void ShouldBatchRevenue() {        
        Test.startTest();
        PressRunDigitalProcess prp = new PressRunDigitalProcess();
        Double testCredit = [SELECT Outstanding_Credit__c FROM Subscription__c LIMIT 1].Outstanding_Credit__c;
        prp.dayOfWeek = 'Monday';
        Id batchId = Database.executeBatch(prp);
        prp.dayOfWeek = 'Tuesday';
        batchId = Database.executeBatch(prp);
        Test.stopTest();
        // Test Subscription
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        System.debug(journalEntries);
        system.assert(journalEntries.size() == 2);
        LastDrawDate__c CurrentDrawDate = LastDrawDate__c.getInstance();
        system.assert(CurrentDrawDate.Last_Date__c == Date.today());
        testCredit = [SELECT Outstanding_Credit__c FROM Subscription__c LIMIT 1].Outstanding_Credit__c;
        system.assert(testCredit == 19.50);
        
    }
}