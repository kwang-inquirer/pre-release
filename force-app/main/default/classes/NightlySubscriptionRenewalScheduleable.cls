global with sharing class NightlySubscriptionRenewalScheduleable implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NightlySubscriptionRenewalBatch());
    }  
}