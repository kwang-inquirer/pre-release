public class Route {
    public String RedeliveryCutOff {get;set;}
    public String Redelivery {get;set;}

    private transient DeliverySchedule deliverySchedule;
    private static String today = System.now().format('EEEE');

    public Route(Delivery_Schedule__c schedule) {
        this.deliverySchedule = new DeliverySchedule(schedule);
        this.RedeliveryCutOff = deliverySchedule.getTodayCutoffTime();
        this.Redelivery = (deliverySchedule.isRedeliveryAllowed()) ? 'Y' : 'N';
    }
}