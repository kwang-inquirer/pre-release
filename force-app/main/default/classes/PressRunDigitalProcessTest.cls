public with sharing class PressRunDigitalProcessTest {
    public PressRunDigitalProcessTest() {

    }
}
@isTest
private class PressRunDigitalProcessTest {
    @testSetup 
    static void setup() {

         Account account = new Account(
            Name = 'Digital A');
        insert account;
        
        Product2 digitalProduct = new Product2(Name = '160', IsDigital__c = true);
        insert digitalProduct;
        Offer__c digitalOffer = new Offer__c(Name = 'Offer1');
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
        
    }
    static testmethod void ShouldBatchRevenue() {        
        Test.startTest();
        PressRunDigitalProcess prp = new PressRunDigitalProcess();
        //prp.activePremium = false;
        prp.dayOfWeek = 'Monday';
        Id batchId = Database.executeBatch(prp);
        prp.dayOfWeek = 'Tuesday';
        batchId = Database.executeBatch(prp);
        Test.stopTest();
        // Test Subscription
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        System.debug(journalEntries);
        system.assert(journalEntries.size() > 0);

        
    }
}