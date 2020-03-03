public without sharing class SubscriptionReceiptController {

    public Subscription__c sub {get; set;}
    public decimal totalFee {get; set;}

    public SubscriptionReceiptController(){
        String subID = ApexPages.currentPage().getParameters().get('id');
        system.debug(subId);
        sub = [SELECT
                        id,
                        Name,
                        subscription_Account__r.Name,
                        subscription_Account__r.ShippingStreet,
                        subscription_Account__r.ShippingCity,
                        subscription_Account__r.ShippingState,
                        subscription_Account__r.ShippingPostalCode,
                        subscription_Account__r.Phone,
                        contact__r.Email,
                        subscription_Account__r.BillingStreet,
                        subscription_Account__r.BillingCity,
                        subscription_Account__r.BillingState,
                        subscription_Account__r.BillingPostalCode,
                        subscription_Offer__r.Total_Amount__c,
                        subscription_Account__r.Owner.Name,
                        subscription_Account__r.Owner.location__c,
                        SignatureURL__c,
                        SignatureAttachmentURL__c
                FROM Subscription__c
                WHERE id =: subID ];
        system.debug(sub.SignatureAttachmentURL__c);

        totalFee = sub.subscription_Offer__r.Total_Amount__c;

    }

}