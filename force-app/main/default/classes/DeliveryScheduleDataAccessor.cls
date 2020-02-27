public class DeliveryScheduleDataAccessor {
    private static String todaysDayOfWeek = System.now().format('EEEE');

    public static List<Delivery_Schedule__c> getCurrentDayDeliverySchedule(String accountId, String routeId) {
        String baseQuery = 'SELECT Id, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c, Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c, Offer_Product__r.Name, Routelookup__r.Redelivery_Allowed__c, subscription_Subscription__r.subscription_Account__c, subscription_Subscription__r.subscription_Status__c, subscription_Subscription__c FROM Delivery_Schedule__c';
        String identifier = (String.isNotEmpty(routeId)) ? 'Routelookup__c = :routeId' : 'subscription_Subscription__r.subscription_Account__c = :accountId';
        String isSubActive = 'subscription_Subscription__r.subscription_Status__c = \'Active\'';
        String todaysFieldIsTrue = 'Day_' + todaysDayOfWeek + '__c' + ' = TRUE';
        return Database.query(String.join(new List<String>{baseQuery, 'WHERE', identifier, 'AND', isSubActive, 'AND', todaysFieldIsTrue}, ' '));
    }

    public static List<Delivery_Schedule__c> getDeliveryScheduleBySubId(Id subId) {
        return [
            SELECT Id, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c, Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c,
                Offer_Product__r.Name, Routelookup__r.Redelivery_Allowed__c, subscription_Subscription__r.subscription_Account__c, Delivery_Address__c, 
                subscription_Subscription__r.subscription_Status__c, subscription_Subscription__c, Routelookup__c, Routelookup__r.District__c,
				subscription_Subscription__r.subscription_Auto_Renew__c
            FROM Delivery_Schedule__c
            WHERE subscription_Subscription__c = :SubId
        ];
    }
}