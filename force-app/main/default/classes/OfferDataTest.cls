@isTest
private class OfferDataTest {
    @testSetup 
    static void setup() {
        TestDataFactory.createTestRecords(3);
    }
    static testmethod void shouldQuerySingleOffer() {        
        Offer__c offer = [SELECT Id FROM Offer__c LIMIT 1];
        offer = OfferDataAccessor.getOfferById(offer.Id);
    }

    static testmethod void shouldQuerySetOffers(){
        Offer__c offer = [SELECT Id FROM Offer__c LIMIT 1];
        Set<Id> offerIds = new Set<Id>();
        offerIds.add(offer.Id);
        List<Offer__c> result = OfferDataAccessor.getOffersByIds(offerIds);
    }

    static testmethod void shouldQueryDigitalOffers(){
        List<Subscription__c> subs = [SELECT Id FROM Subscription__c];
        Set<Id> subIds = new Set<Id>();
        for(Subscription__c sub : subs){
            subIds.add(sub.Id);
        }
        List<Offer__c> result = OfferDataAccessor.getSubscriptionDigitalOffers(subIds);
    }
    
}