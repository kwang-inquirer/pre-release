public with sharing class SubscriptionDelivery {
    private static final List<String> days = new List<String>{'Sun', 'Mon', 'Tue' , 'Wed', 'Thu', 'Fri', 'Sat'};

    public static Date getEarliestStopDate(List<Delivery_Schedule__c> deliverySchedules) {
        Date currentDate = Date.today();    // set current date
        Date calcDate    = Date.today();    // incremental date to be compared to current date
        Integer numberDays = 0;
        Boolean afterCutOff = false;

        // outer loop by day
        for (Integer i = 0; i < 365; i++) {
            String currentDayOfWeek = DateTime.newInstance(calcDate, Time.newInstance(0, 0, 0, 0)).format('EEE');

            // inner loop by day in delivery schedule
            for (Delivery_Schedule__c schedule : deliverySchedules) {
                if (hasDelivery(schedule, currentDayOfWeek)) {

                    if (afterCutOff && !currentDate.isSameDay(calcDate)) {
                        // return after cutoff available date
                        return calcDate;
                    }

                    numberDays = currentDate.daysBetween(calcDate);
                    if( (currentDate < calcDate) && (numberDays == 1) ){
                        //
                        // check for cutoff when delivery is tomorrow
                        //
                        Boolean beforeCutOff = CutOffManager.isBeforeCutOff('Carrier Memo');
                        if (beforeCutOff) {
                            return calcDate;
                        } else {
                            // set to true for returning next available date
                            afterCutOff = true;
                        }
                    }

                    // afterCutOff unchanged AND incremented date : return next available date
                    if (!afterCutOff && !currentDate.isSameDay(calcDate)) {
                        return calcDate;
                    }
                }
            }
            calcDate = calcDate.addDays(1);
        }
        return null;
    }
    
    private static Boolean hasDelivery(Delivery_Schedule__c schedule, String dayOfWeek) {
        if(schedule.Day_Sunday__c && dayOfWeek == 'Sun') {
			return true;
        }
        if(schedule.Day_Monday__c && dayOfWeek == 'Mon') {
			return true;
        }
        if(schedule.Day_Tuesday__c && dayOfWeek == 'Tue') {
			return true;
        }
        if(schedule.Day_Wednesday__c && dayOfWeek == 'Wed') {
			return true;
        }
        if(schedule.Day_Thursday__c && dayOfWeek == 'Thu') {
			return true;
        }
        if(schedule.Day_Friday__c && dayOfWeek == 'Fri') {
			return true;
        }
        if(schedule.Day_Saturday__c && dayOfWeek == 'Sat') {
			return true;
        }
		return false;
	}
}