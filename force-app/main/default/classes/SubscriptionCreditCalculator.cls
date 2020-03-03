public with sharing class SubscriptionCreditCalculator {
    private Subscription__c subscription;
    private Offer__c offer;

    private Date endDate;
    private Date startDate;
    private Set<Id> offerProductIds;

    private Decimal totalCredit;
    private Map<Id, Decimal> amountPerProduct;

    public SubscriptionCreditCalculator(Id subscriptionId, Date startDate, Date endDate, List<Id> offerProductIds) {
        this.subscription = SubscriptionDataAccessor.getSubscriptionById(subscriptionId);
        this.offer = OfferDataAccessor.getOfferById(subscription.subscription_Offer__c);        
        this.startDate = startDate;
        this.endDate = endDate;
        this.offerProductIds = new Set<Id>(offerProductIds);
    }

    public Decimal calculate() {
        totalCredit = 0;
        amountPerProduct = new Map<Id, Decimal>();
        sumCreditFromSchedules();
        sumCreditFromDigitalProducts();
        return totalCredit;
    }

    public Map<Id, Decimal> getAmountPerProduct() {
        if (amountPerProduct == null) {
            calculate();
        }
        return amountPerProduct;
    }

    private void sumCreditFromSchedules() {
        if (subscription.Delivery_Schedules__r == null) {
            return;
        }
        for (Delivery_Schedule__c schedule : subscription.Delivery_Schedules__r) {
            if (schedule.Start_Date__c <= startDate && schedule.End_Date__c >= endDate && offerProductIds.contains(schedule.Offer_Product__c)) {
                Integer regularDays = 0;
                Integer sundayDays = 0;
                Date currentDate = startDate;

                while (currentDate <= endDate) {
                    if (isScheduledAndRegularDay(currentDate, schedule)) {
                        regularDays++;
                    }
                    if (isScheduledAndSundayDay(currentDate, schedule)) {
                        sundayDays++;
                    }
                    currentDate = currentDate.addDays(1);
                }
                Decimal offerProdPerCopy = schedule.Offer_Product__r.Per_Copy__c;
                Decimal offerProdPerCopySunday = schedule.Offer_Product__r.Per_Copy_Sunday__c;
                Decimal combinedAmount = (offerProdPerCopy * regularDays) + (offerProdPerCopySunday * sundayDays);
                totalCredit += combinedAmount;
                amountPerProduct.put(schedule.Offer_Product__r.Product__c, combinedAmount);
            }
        }
    }

    private void sumCreditFromDigitalProducts() {
        if (offer == null || offer.Offer_Products__r == null) {
            return;
        }
        for (Offer_Product__c offerProduct : offer.Offer_Products__r) {
            if (offerProductIds.contains(offerProduct.Id) && offerProduct.Is_Digital__c) {
                
            }
        }
    }

    private Boolean isScheduledAndRegularDay(Date currentDate, Delivery_Schedule__c schedule) {
        Datetime dtime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dtime.format('EEEE');
        return ((dayOfWeek == 'Monday' && schedule.Day_Monday__c) || 
            (dayOfWeek == 'Tuesday' && schedule.Day_Tuesday__c) || 
            (dayOfWeek == 'Wednesday' && schedule.Day_Wednesday__c) || 
            (dayOfWeek == 'Thursday' && schedule.Day_Thursday__c) || 
            (dayOfWeek == 'Friday' && schedule.Day_Friday__c) || 
            (dayOfWeek == 'Saturday' && schedule.Day_Saturday__c));
    }

    private Boolean isScheduledAndSundayDay(Date currentDate, Delivery_Schedule__c schedule) {
        Datetime dtime = DateTime.newInstance(currentDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dtime.format('EEEE');
        return (dayOfWeek == 'Sunday' && schedule.Day_Sunday__c);
    }

    private Integer getSundayDays(Delivery_Schedule__c schedule) {
        Integer sundayDays = 0;
        if (schedule.Day_Sunday__c) {
            sundayDays++;
        }
        return sundayDays;
    }
}