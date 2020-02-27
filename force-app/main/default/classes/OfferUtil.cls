public class OfferUtil {
    private List<Offer__c> newList;
    private List<Offer__c> oldList;
    private Map<Id,Offer__c> newMap;
    private Map<Id,Offer__c> oldMap;
    public OfferUtil(List<Offer__c> newListParam, List<Offer__c> oldListParam, Map<Id,Offer__c> newMapParam, Map<Id,Offer__c> oldMapParam) {
        newList = newListParam;
        oldList = oldListParam;
        newMap = newMapParam;
        oldMap = oldMapParam;
    }

    public void insertRecurlyPlan(){

        List<recurly_v2__Plan__c> toInsert = new List<recurly_v2__Plan__c>();
        for(Offer__c offer : newList){

            Map<String, Object> fieldsToValue = offer.getPopulatedFieldsAsMap();
            recurly_v2__Plan__c rcPlan = new recurly_v2__Plan__c();
            for(String fieldName : fieldsToValue.keySet()){
                Schema.SObjectField field = Schema.sObjectType.recurly_v2__Plan__c.fields.getMap().get(fieldName);
                if(field != null && field.getDescribe().isAccessible() && field.getDescribe().isUpdateable()){
                    rcPlan.put(fieldName, fieldsToValue.get(fieldName));
                } 
            }
            rcPlan.recurly_v2__PlanID__c = 'Default';
            toInsert.add(rcPlan);
        }
        if(!toInsert.isEmpty())
            insert toInsert;
    }
    
}