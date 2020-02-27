public class SubscriptionUtil {
    private List<Subscription__c> newList;
    private List<Subscription__c> oldList;
    private Map<Id,Subscription__c> newMap;
    private Map<Id,Subscription__c> oldMap;
    public SubscriptionUtil(List<Subscription__c> newListParam, List<Subscription__c> oldListParam, Map<Id,Subscription__c> newMapParam, Map<Id,Subscription__c> oldMapParam) {
        newList = newListParam;
        oldList = oldListParam;
        newMap = newMapParam;
        oldMap = oldMapParam;
    }
    public void insertRecurlySubscription(){
        Set<Id> accountIds = new Set<Id>();
        for(Subscription__c subscription : newList){
            accountIds.add(subscription.subscription_Account__c);
        }
        System.debug('accountIds: ' + accountIds);
        
        Map<Id, recurly_v2__Recurly_Account__c> subscriptionToRecurlyAccountId = new Map<Id, recurly_v2__Recurly_Account__c>([
            SELECT Id 
            FROM recurly_v2__Recurly_Account__c 
            WHERE recurly_v2__Account__c IN :accountIds
        ]);
        System.debug('map: ' + subscriptionToRecurlyAccountId);
        List<recurly_v2__Recurly_Subscription__c> toInsert = new List<recurly_v2__Recurly_Subscription__c>();
        for(Subscription__c subscription : newList){

            Map<String, Object> fieldsToValue = subscription.getPopulatedFieldsAsMap();
            recurly_v2__Recurly_Subscription__c rcSubscription = new recurly_v2__Recurly_Subscription__c();
            for(String fieldName : fieldsToValue.keySet()){
                Schema.SObjectField field = Schema.sObjectType.recurly_v2__Recurly_Subscription__c.fields.getMap().get(fieldName);
                if(field != null && field.getDescribe().isAccessible() && field.getDescribe().isUpdateable()){
                    rcSubscription.put(fieldName, fieldsToValue.get(fieldName));
                } 
            }
            Id rcAccountId = subscriptionToRecurlyAccountId.get(subscription.subscription_Account__c) != null ?
            subscriptionToRecurlyAccountId.get(subscription.subscription_Account__c).Id : createRcAccount(subscription);
            rcSubscription.recurly_v2__SubscriptionID__c = rcAccountId;
            rcSubscription.recurly_v2__Recurly_Account__c = rcAccountId;
            
            toInsert.add(rcSubscription);
        }
        if(!toInsert.isEmpty())
            insert toInsert;
    }

    private Id createRcAccount(Subscription__c subscription){
        recurly_v2__Recurly_Account__c toInsert = new recurly_v2__Recurly_Account__c();
        toInsert.recurly_v2__Account__c = subscription.subscription_Account__c;
        insert toInsert;
        return toInsert.Id;
    }
}