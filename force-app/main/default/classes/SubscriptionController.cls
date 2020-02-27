public with sharing class SubscriptionController {
    @AuraEnabled
    public static Subscription__c getSubscriptionById(String subId){
        return SubscriptionDataAccessor.getSubscriptionById(subId);
    }

    @AuraEnabled
    public static void updateSubscription(Subscription__c subscription) {
        update subscription;
    }

    @AuraEnabled
    public static Subscription__c getDefaultNewSubscription(String offerId, String email, String source, String password, Boolean waiveActivationFee) {
        try {
            return CheckoutSubscriptionCreator.getNewSubscription(offerId, email, source, password, waiveActivationFee);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve the subscription');
        }
    }
}