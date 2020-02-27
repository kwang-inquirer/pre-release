public with sharing class SubscriptionTriggerHandler {
	private List<Subscription__c> newList;
	private List<Subscription__c> oldList;
	private Map<Id,Subscription__c> newMap;
	private Map<Id,Subscription__c> oldMap;

	private Set<Id> offerIds;
	private Map<Id, Offer__c> offers {
		get {
			if (offers == null) {
				offers = new Map<Id, Offer__c>(OfferDataAccessor.getOffersByIds(offerIds));
			}
			return offers;
		} private set;
	}

	public SubscriptionTriggerHandler(List<Subscription__c> newList, List<Subscription__c> oldList, Map<Id,Subscription__c> newMap, Map<Id,Subscription__c> oldMap) {
		this.newList = newList;
		this.oldList = oldList;
		this.newMap = newMap;
		this.oldMap = oldMap;
		init();
	}
	
	public void onBeforeInsert() {
		for (Subscription__c subscription : newList) {
			setOfferRelatedFields(subscription);
		}
	}

	private void setOfferRelatedFields(Subscription__c subscription) {
		if (offers != null) {
			Offer__c offer = offers.get(subscription.subscription_Offer__c);
			if (offer != null) {
				subscription.Pending_Offer__c = offer.Renewal_Offer__c;
			}
		}
	}

	private void init() {
		offerIds = new Set<Id>();
		for (Subscription__c subscription : newList) {
			if (subscription.subscription_Offer__c != null) {
				offerIds.add(subscription.subscription_Offer__c);
			}
		}
	}
}