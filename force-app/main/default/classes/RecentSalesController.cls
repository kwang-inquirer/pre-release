public with sharing class RecentSalesController {

    public List<Subscription__c> subs{get; set;}
    public Id currentUser{get; set;}


    public RecentSalesController() {
        currentUser = UserInfo.getUserId();
        subs = [SELECT Contact__r.Name, subscription_Offer__r.Name,subscription_Offer__r.Offer_Name__c,CreatedDate FROM subscription__c WHERE subscription_Account__r.OwnerId=:currentUser ORDER BY CreatedDate desc LIMIT 10];

    }
}