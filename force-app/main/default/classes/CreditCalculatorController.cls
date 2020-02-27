/**
* Controller for CreditCalculator.cmp
*/

global with sharing class CreditCalculatorController {
    @AuraEnabled
    public static Subscription__c fetchSubscription(Id subId) {
        return [SELECT Id, Outstanding_Credit__c FROM Subscription__c WHERE Id = :subId];
    }
    
    @AuraEnabled
    public static List<Offer_Product__c> fetchOfferProducts(Id subId) {
        Subscription__c sub = [SELECT Id, subscription_Offer__c FROM Subscription__c WHERE Id = :subId];
        return [SELECT Id, Name FROM Offer_Product__c WHERE Offer__c = :sub.subscription_Offer__c AND Is_Activation_Fee__c = FALSE];
    }

    @AuraEnabled
    public static Decimal calculate(String subscriptionId, Date startDate, Date endDate, List<String> offerProductIds) {
        if (startDate > endDate) {
            throw new GenericException('Start date cannot come after end date');
        }

        SubscriptionCreditCalculator calculator = new SubscriptionCreditCalculator(subscriptionId, startDate, endDate, offerProductIds);
        return calculator.calculate();
    }

    @AuraEnabled
    public static DateTime submit(Id subscriptionId, Id transactionType, Decimal amount, String paymentType, String message, Date startDate, Date endDate, List<Id> offerProductIds) {
        if(amount == null || amount <= 0) {
            throw new GenericException('Invalid amount');
        } 

        if (startDate > endDate) {
            throw new GenericException('Start date cannot come after end date');
        }

        Subscription__c subscription = SubscriptionDataAccessor.getSubscriptionById(subscriptionId);
        if (offerProductIds != null && offerProductIds.size() > 0) {
            createJournalsForSelectedProducts(subscription, offerProductIds, amount, paymentType, message, startDate, endDate);
        } else {
            createJournalForSubscription(subscription, amount, paymentType, message);
        }

        return subscription.subscription_Current_Period_Ends_At__c;
    }
    
	@AuraEnabled
    public static DateTime ApplyCreditToSubscription(String subscriptionId, Decimal credit){
        Subscription__c sub = [SELECT Id, subscription_Account__c,Contact__c,Outstanding_Credit__c,
                               subscription_Current_Period_Ends_At__c, subscription_Offer__r.Per_CopyRollup__c, subscription_Offer__r.Per_Copy_SundayRollup__c,
                               (SELECT id, Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c, Status__c 
                                FROM Delivery_Schedules__r 
                                WHERE Status__c = 'Active') 
                               FROM Subscription__c 
                               WHERE id=:subscriptionId];
        sub.id = subscriptionId;
        Integer mfCount=0, satCount=0, sunCount = 0;

		
        //ExtendExpiration
        Set<String> deliveryDays = new Set<String>();
        for(Delivery_Schedule__c ds:sub.Delivery_Schedules__r) {
            if(ds.Day_Sunday__c) {
                deliveryDays.add('Sun');
                sunCount++;
            }
            if(ds.Day_Monday__c) {
                deliveryDays.add('Mon');
                mfCount++;
            }
            if(ds.Day_Tuesday__c) {
                deliveryDays.add('Tue');
            }
            if(ds.Day_Wednesday__c) {
                deliveryDays.add('Wed');
            }
            if(ds.Day_Thursday__c) {
                deliveryDays.add('Thu');
            }
            if(ds.Day_Friday__c) {
                deliveryDays.add('Fri');
                mfCount++;
            }
            if(ds.Day_Saturday__c) {
                deliveryDays.add('Sat');
                satCount++;
            }
        }
        if(sub.Outstanding_Credit__c == null){
            sub.Outstanding_Credit__c = 0.0;
        }
        sub.Outstanding_Credit__c = sub.Outstanding_Credit__c + credit;
        Date dayAfterSubExpDate = sub.subscription_Current_Period_Ends_At__c.addDays(1);
        
        for(Integer i = 0; i<365; i++){
            Datetime dtdayAfterSubExpDate = DateTime.newInstance(dayAfterSubExpDate, Time.newInstance(0, 0, 0, 0));
            String dayOfWeek = dtdayAfterSubExpDate.format('EEE');
            if(deliveryDays.contains(dayOfWeek) && dayofWeek == 'Sun' && sub.Outstanding_Credit__c > sub.subscription_Offer__r.Per_Copy_SundayRollup__c){
                sub.subscription_Current_Period_Ends_At__c = dayAfterSubExpDate;
                sub.Outstanding_Credit__c = sub.Outstanding_Credit__c - sub.subscription_Offer__r.Per_Copy_SundayRollup__c;
                dayAfterSubExpDate = dayAfterSubExpDate.addDays(1);
            }
            else if(deliveryDays.contains(dayOfWeek) && sub.Outstanding_Credit__c > sub.subscription_Offer__r.Per_CopyRollup__c) {
                sub.subscription_Current_Period_Ends_At__c = dayAfterSubExpDate;
                sub.Outstanding_Credit__c = sub.Outstanding_Credit__c - sub.subscription_Offer__r.Per_CopyRollup__c;
                dayAfterSubExpDate = dayAfterSubExpDate.addDays(1);
            }
            else if(deliveryDays.contains(dayOfWeek)) {
                break;
            }
            else {
                dayAfterSubExpDate = dayAfterSubExpDate.addDays(1);
            }
        }

        update sub;
        
        return dayAfterSubExpDate;
    }
    
    public static void ApplyAdjustment(Subscription__c subscription, Offer__c digitalOffer) {
        List<String> days = new List<String>{'Sun', 'Mon', 'Tue' , 'Wed', 'Thu', 'Fri', 'Sat'};

        if(subscription.Outstanding_Credit__c <= 0) {
            return;  
        } 

        Date startDate = Date.today();
        if (subscription.subscription_Status__c == 'Active' && subscription.subscription_Current_Period_Ends_At__c != null) {
            startDate = subscription.subscription_Current_Period_Ends_At__c.addDays(1);
        }

        DateTime dateIterator = DateTime.newInstance(startDate, Time.newInstance(12, 0, 0 ,0));
        String dayOfWeek = '';
        Offer_Product__c op;
        Decimal digitalDaily = 0.0;
        Decimal digitalSunday = 0.0;
        Decimal weeklyPrintRate = 0.0;

        Map<String, Decimal> dayToRateMap = new Map<String, Decimal>();
        if(subscription.Number_of_Active_Delivery_Schedules__c > 0){
            for(String day : days){
                for(Delivery_Schedule__c ds  : subscription.Delivery_Schedules__r){
                    if(HasDelivery(ds, day)){
                        Decimal dayAmount = dayToRateMap.get(day);
                        Decimal amountToUse = day == 'Sun' ? ds.Offer_Product__r.Per_Copy_Sunday__c : ds.Offer_Product__r.Per_Copy__c;
                        if (dayAmount == null) {
                            dayAmount = 0;
                        }
                        dayAmount += amountToUse;
                        weeklyPrintRate += amountToUse;
                        dayToRateMap.put(day, dayAmount);
                    }
                }
            }
        }
        
        /* Query for Digital Offer Products related to a subscription */
        if (digitalOffer != null && !digitalOffer.Offer_Products__r.isEmpty()) {
            op = digitalOffer.Offer_Products__r[0];
            digitalDaily = op.Per_Copy__c;
            digitalSunday = op.Per_Copy_Sunday__c;
        }

        /*Iterate daily until the subscription does not have enough balance to continue, then break.*/
        Decimal balance = subscription.Outstanding_Credit__c;
        while(true) {
            Decimal rate = 0.0;
            dayOfWeek = dateIterator.format('EEE');
            if(dayToRateMap.containsKey(dayOfWeek)){
                    rate += dayToRateMap.get(dayOfWeek);
            }
            
            if(op != null){
                rate += dayOfWeek == 'Sun' ? digitalSunday : digitalDaily;
            }

            System.debug('Balance: ' + balance + '   Rate: ' + rate + '   Date: ' + dateIterator.date() + '   End Date: ' + dateIterator.date());

            if((subscription.Number_of_Active_Delivery_Schedules__c == 0 || weeklyPrintRate <= 0.0) && (op == null || (digitalSunday <= 0.0 && digitalSunday <= 0.0))) {
                break;
            }
            
            if(balance > rate){
                balance -= rate;
                dateIterator = dateIterator.addDays(1);
            } else{
                subscription.subscription_Current_Period_Ends_At__c = dateIterator.date();
                subscription.Outstanding_Credit__c = balance;
                subscription.Expire_Balance__c = balance;
                break;
            }
            
        }    
    }

     public static void ApplyAdjustment(List<Subscription__c> subscriptions) {
        List<String> days = new List<String>{'Sun', 'Mon', 'Tue' , 'Wed', 'Thu', 'Fri', 'Sat'};
        Map<Id, Subscription__c> subscriptionsById = new Map<Id, Subscription__c>(subscriptions);
        Map<Id, Offer__c> offersMap = new Map<Id, Offer__c>(OfferDataAccessor.getSubscriptionDigitalOffers(subscriptionsById.keySet()));
        for(Subscription__c subscription : subscriptions){
            Offer__c digitalOffer = offersMap.get(subscription.subscription_Offer__c);
            ApplyAdjustment(subscription, digitalOffer);
        }
        update subscriptions;
    }

    private static Boolean HasDelivery(Delivery_Schedule__c ds, String dayOfWeek){
		Boolean booResult = false;
        if(ds.Day_Sunday__c && dayOfWeek == 'Sun')
        {
			return true;
        }
        if(ds.Day_Monday__c && dayOfWeek == 'Mon')
        {
			return true;
        }
        if(ds.Day_Tuesday__c && dayOfWeek == 'Tue')
        {
			return true;
        }
        if(ds.Day_Wednesday__c && dayOfWeek == 'Wed')
        {
			return true;
        }
        if(ds.Day_Thursday__c && dayOfWeek == 'Thu')
        {
			return true;
        }
        if(ds.Day_Friday__c && dayOfWeek == 'Fri')
        {
			return true;
        }
        if(ds.Day_Saturday__c && dayOfWeek == 'Sat')
        {
			return true;
        }
		return booResult;
	}

    private static void createJournalsForSelectedProducts(Subscription__c subscription, List<Id> offerProductIds, Decimal amount, String paymentType, String message, Date startDate, Date endDate) {
        List<Journal__c> journalsToInsert = new List<Journal__c>();
        SubscriptionCreditCalculator calculator = new SubscriptionCreditCalculator(subscription.Id, startDate, endDate, offerProductIds);
        Map<Id, Decimal> amountPerOfferProduct = calculator.getAmountPerProduct();
        for (Id productId : amountPerOfferProduct.keySet()) {
            Decimal offerProductTotal = amountPerOfferProduct.get(productId);
            Decimal creditAmount = (paymentType == 'Credit') ? amount : null;
            Decimal debitAmount = (paymentType == 'Debit') ? amount : null;
            journalsToInsert.add(createJournal(subscription.Id, productId, Date.today(), Date.today(), message, 'Adjustment', creditAmount, debitAmount));
        }
        if (!journalsToInsert.isEmpty()) {
            insert journalsToInsert;
        }
    }

    private static void createJournalForSubscription(Subscription__c subscription, Decimal amount, String paymentType, String message) {
        Decimal creditAmount = (paymentType == 'Credit') ? amount : null;
        Decimal debitAmount = (paymentType == 'Debit') ? amount : null;
        insert createJournal(subscription.Id, null, Date.today(), Date.today(), message, 'Adjustment', creditAmount, debitAmount);
    }

    private static Journal__c createJournal(Id subscriptionId, Id productId, Date effectiveDate, Date entryDate, String description, String entryType, Decimal credit, Decimal debit) {
        return new Journal__c(
            Subscription__c = subscriptionId,
            Publication__c = productId,
            Effective_Date__c = effectiveDate,
            Entry_Date__c = entryDate,
            Description__c = description,
            Entry_Type__c = entryType, 
            Credit__c = credit,
            Debit__c = debit
        );
    }
}