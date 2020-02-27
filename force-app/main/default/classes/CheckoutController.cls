public with sharing class CheckoutController {   
    @AuraEnabled
    public static string getRecurlyJsUrl() {
        User usr = getUserInfo();
        if (usr.Profile.Name.contains('Community')) {
            String ntwrkId = Network.getNetworkId();
            System.debug('Network Id: ' + ntwrkId);
            ConnectApi.Community comm = ConnectApi.Communities.getCommunity(ntwrkId);
            return comm.siteUrl + '/apex/recurlyjs';
        }
        return Label.RECURLYJS_VFP_URL;
    }
    
    @AuraEnabled
    public static User getUserInfo() {
       return [SELECT Id, Name, Profile.Name, Profile.UserLicense.Name FROM User WHERE Id = :UserInfo.getUserId()];
    }

    @AuraEnabled
    public static Subscription__c getSubscriptionById(String subId){
        return SubscriptionDataAccessor.getSubscriptionById(subId);
    }

    @AuraEnabled
    public static Offer__c getOfferById(String offerId) {
        try {
            return OfferDataAccessor.getOfferById(offerId);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve the offer');
        }
    }

    @AuraEnabled
    public static void callPiano(String pianoId){
        try {
            Map<String, Object> res = new PianoClient().callPiano(pianoId);
            if ((Integer)res.get('code') != 0) {
                throw new GenericException('Failed to call piano api: ' + (String)res.get('message'));
            }
        }
        catch (Exception e) {
            throw new AuraHandledException('Failed to call piano api: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Subscription__c getNewSubscription(String offerId, String email, String source, String password, Boolean waiveActivationFee) {
        try {
            return CheckoutSubscriptionCreator.getNewSubscription(offerId, email, source, password, waiveActivationFee);
        } catch (GenericException e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to retrieve the subscription');
        }
    }

    @AuraEnabled
    public static void saveDeliveryAddress(Id subId, Map<String, String> address) {
        try {
            new CheckoutProcess(subId).updateDeliveryAddress(address);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to save delivery address');
        }
    }

    @AuraEnabled
    public static void saveBillingAddress(Id subId, Map<String, String> address) {
        try {
            new CheckoutProcess(subId).updateBillingAddress(address);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to save billing address');
        }
    }

    @AuraEnabled
    public static Boolean hasValidDeliveryAddress(Id subId) {
        try {
            return new CheckoutProcess(subId).hasValidDeliveryAddress();
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to validate delivery address');
        }
    }

    @AuraEnabled()
    public static void saveAgreementSignature(String subId, String signatureUrl) {
        try {
            new CheckoutProcess(subId).saveAgreement(signatureUrl);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to update the agreement');
        }
    }

    @AuraEnabled
    public static Id createRecurlyAccount(Id subId) {
        try {
            return new CheckoutProcess(subId).createRecurlyAccount();
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create the account');
        }
    }

    @AuraEnabled
    public static void submitPayment(Id subId, String paymentJson) { 
        try {
            CheckoutPaymentInformation payment = (CheckoutPaymentInformation)JSON.deserialize(paymentJson, CheckoutPaymentInformation.Class);
            new CheckoutProcess(subId).submitPayment(payment);
        } catch (GenericException e) { 
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException('Failed to submit the payment');
        }
    }
}