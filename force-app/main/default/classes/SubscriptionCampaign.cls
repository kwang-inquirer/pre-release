public with sharing class SubscriptionCampaign {
    private Offer__c offer;
    private Subscription__c subscription;
    private Map<String, Campaign_Settings__mdt> campaignSettingsByName;

    private static final String CAMPAIGN_SETTING_FREE_TRIAL = 'Free_Trial';
    private static final String CAMPAIGN_SETTING_ABANDONED_CART = 'Abandoned_Cart';
    private static final String CAMPAIGN_SETTING_ONBOARDING_NEW = 'Onboarding_New';
    private static final String CAMPAIGN_SETTING_ONBOARDING_LAPSED = 'Onboarding_Lapsed';
    private static final String CAMPAIGN_SETTING_ONBOARDING_OLD = 'Onboarding_Old';

    public SubscriptionCampaign(Subscription__c subscription) {
        this.offer = offer;
        this.subscription = subscription;
        this.campaignSettingsByName = getCampaignSettingsByName();
    }

    public void setNewSubscriptionCampaign() {
        String campaignToUse = (subscription.subscription_Offer__r.Free_Trial__c) ? CAMPAIGN_SETTING_FREE_TRIAL : CAMPAIGN_SETTING_ABANDONED_CART;
        Campaign_Settings__mdt campaignSettings = campaignSettingsByName.get(campaignToUse);
        setCurrentCampaign(campaignSettings);
    }

    public void setCheckoutCompleteCampaign() {
        // Determine which campaign we need to push into 
        Campaign_Settings__mdt campaignSettings = campaignSettingsByName.get(CAMPAIGN_SETTING_ONBOARDING_NEW);
        if (subscription.subscription_Status__c == 'Expired') {
            campaignSettings = campaignSettingsByName.get(CAMPAIGN_SETTING_ONBOARDING_LAPSED);
            if (subscription.Expires_On__c.daysBetween(Date.today()) > 90) { // if expired more than 90 days mark as old
                campaignSettings = campaignSettingsByName.get(CAMPAIGN_SETTING_ONBOARDING_OLD);
            }
        }
        if (campaignSettings != null) {
            setCurrentCampaign(campaignSettings);
        }
    }

    private void setCurrentCampaign(Campaign_Settings__mdt campaignSettings) {
        if (campaignSettings != null) {
            removeCurrentCampaigns();
            List<Campaign> campaigns = [SELECT Id FROM Campaign WHERE Id = :campaignSettings.Campaign_Id__c];
            if (!campaigns.isEmpty()) {
                CampaignMember campaignMember = new CampaignMember(CampaignId = campaignSettings.Campaign_Id__c, ContactId = subscription.Contact__c);
                insert campaignMember;
            }
        }
    }

    private Map<String, Campaign_Settings__mdt> getCampaignSettingsByName() {
        Map<String, Campaign_Settings__mdt> campaignSettingByName = new Map<String, Campaign_Settings__mdt>();
        List<Campaign_Settings__mdt> campaignSettings = [SELECT Id, Campaign_Id__c, Campaign_Name__c, DeveloperName FROM Campaign_Settings__mdt];
        for (Campaign_Settings__mdt campaignSetting : campaignSettings) {
            campaignSettingByName.put(campaignSetting.DeveloperName, campaignSetting);
        }
        return campaignSettingByName;
    }   

    private void removeCurrentCampaigns() {
        Set<Id> campaignIds = new Set<Id>();
        for (Campaign_Settings__mdt campaignSetting : campaignSettingsByName.values()) {
            campaignIds.add(campaignSetting.Campaign_Id__c);
        }

        List<CampaignMember> currentCampaigns = [SELECT Id FROM CampaignMember WHERE ContactId = :subscription.Contact__c AND CampaignId IN :campaignIds];
        if (!currentCampaigns.isEmpty()) {
            delete currentCampaigns;
        }
    }
}