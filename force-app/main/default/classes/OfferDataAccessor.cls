public with sharing class OfferDataAccessor {
    public static Offer__c getOfferById(Id offerId) {
        return [
            SELECT Id, Name, Per_Week__c, Number_of_Weeks__c, Total_Amount__c, Start_Date__c, End_Date__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c, Free_Trial__c,
                (SELECT Id, Name, Is_Activation_Fee__c, Is_Digital__c, Monday__c, Tuesday__c, Wednesday__c, Thursday__c, Friday__c, Saturday__c, Sunday__c, Product__r.Name, Product__c, Per_Copy__c, Per_Copy_Sunday__c, Activation_Fee__c FROM Offer_Products__r)
            FROM Offer__c 
            WHERE Id = :offerId
        ];
    }

    public static List<Offer__c> getOffersByIds(Set<Id> offerIds) {
        return [
            SELECT Id, Renewal_Offer__c
            FROM Offer__c 
            WHERE Id IN :offerIds
        ];
    }

    public static List<Offer__c> getSubscriptionDigitalOffers(Set<Id> subscriptionIds) {
        return [
            SELECT Id, (SELECT Name, Product__c, Per_Copy__c, Per_Copy_Sunday__c, subscription_Offer__c FROM Offer_Products__r WHERE Is_Digital__c = TRUE) 
            FROM Offer__c 
            WHERE Id in (SELECT subscription_Offer__c FROM Subscription__c WHERE Id IN :subscriptionIds)
        ];
    }
}