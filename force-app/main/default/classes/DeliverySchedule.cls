public class DeliverySchedule {
    public Delivery_Schedule__c schedule;

    private static String todaysDayOfWeek = System.now().format('EEEE');

    public DeliverySchedule(Delivery_Schedule__c schedule) {
        this.schedule = schedule;
    }

    public String getTodayCutoffTime() {
        if (isScheduledForToday()) {
            List<Cut_Offs_Time__mdt> times = [SELECT Hour__c, Minute__c FROM Cut_Offs_Time__mdt WHERE Day_of_Week__c = :todaysDayOfWeek LIMIT 1];
            if (!times.isEmpty()) {
                return String.valueOf(times[0].Hour__c).leftPad(2, '0') + ':' + String.valueOf(times[0].Minute__c).leftPad(2, '0');
            }
        }
        return null;
    }

    public Boolean isScheduledForToday() {
        return schedule.Day_Sunday__c && todaysDayOfWeek == 'Sunday' ||
            schedule.Day_Monday__c && todaysDayOfWeek == 'Monday' ||
            schedule.Day_Tuesday__c && todaysDayOfWeek == 'Tuesday' ||
            schedule.Day_Wednesday__c && todaysDayOfWeek == 'Wednesday' ||
            schedule.Day_Thursday__c && todaysDayOfWeek == 'Thursday' ||
            schedule.Day_Friday__c && todaysDayOfWeek == 'Friday' ||
            schedule.Day_Saturday__c && todaysDayOfWeek == 'Saturday';
    }

    public Boolean isRedeliveryAllowed() {
        return schedule.Routelookup__r.Redelivery_Allowed__c;
    }

    public String getScheduleForWeek() {
        String scheduleForWeek = '';
        scheduleForWeek += (schedule.Day_Sunday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Monday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Tuesday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Wednesday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Thursday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Friday__c) ? 'Y' : 'N';
        scheduleForWeek += (schedule.Day_Saturday__c) ? 'Y' : 'N';
        return scheduleForWeek;
    }

    public Boolean hasEscalatedCases() {
        List<Case> escalatedCases = [SELECT Id FROM Case WHERE Subscription__c = :schedule.subscription_Subscription__c AND Status = 'Escalated' AND IsEscalated = TRUE];
        return !escalatedCases.isEmpty();
    }

    public Transaction_Log__c getLastestComplaint() {
        List<Transaction_Log__c> lastComplaints = TransactionDataAccessor.getLatestComplaintTransactions(schedule.subscription_Subscription__r.subscription_Account__c, 1);
        if (!lastComplaints.isEmpty()) {
            return lastComplaints[0];
        }
        return null;
    }

    public static List<Delivery_Schedule__c> getCurrentDayDeliverySchedule(String accountId, String routeId) {
        String baseQuery = 'SELECT Id FROM Delivery_Schedule__c';
        String identifier = (String.isNotEmpty(routeId)) ? 'Routelookup__c = :routeId' : 'subscription_Subscription__r.subscription_Account__c = :accountId';
        String isSubActive = 'subscription_Subscription__r.subscription_Status__c = \'Active\'';
        String todaysFieldIsTrue = 'Day_' + todaysDayOfWeek + '__c' + ' = TRUE';
        return Database.query(String.join(new List<String>{baseQuery, 'WHERE', identifier, 'AND', isSubActive, 'AND', todaysFieldIsTrue}, ' '));
    }
}