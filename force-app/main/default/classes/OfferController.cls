public with sharing class OfferController {
    @AuraEnabled
    public static Offer__c getOfferById(String offerId) {
        try {
            return OfferDataAccessor.getOfferById(offerId);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve the offer');
        }
    }
}