public class ServiceInfo {
    public String Account {get;set;}
    public String ProductName {get;set;}
    public String ServiceType {get;set;}
    public String AllowComplaints {get;set;}
    public String DelayTime {get;set;}
    public String ReDeliverableRoute {get;set;}
    public String RouteLate {get;set;}
    public String LastComplaint {get;set;}
    public String ExistingComplaint {get;set;}
    public String ExcessiveComplaint {get;set;}
    public String Cutoff {get;set;}

    private DeliverySchedule deliverySchedule;

    public ServiceInfo(Delivery_Schedule__c schedule) {
        this.deliverySchedule = new DeliverySchedule(schedule);

        Transaction_Log__c latestComplaint = deliverySchedule.getLastestComplaint();
        Date latestComplaintDate = latestComplaint != null ? latestComplaint.Date__c : null;

        this.Account = schedule.subscription_Subscription__r.subscription_Account__c;
        this.ProductName = schedule.Offer_Product__r.Name;
        this.ServiceType = deliverySchedule.getScheduleForWeek();
        this.AllowComplaints = 'Y'; // todo
        this.DelayTime = '12'; // todo
        this.ReDeliverableRoute = (schedule.Routelookup__r.Redelivery_Allowed__c) ? 'Y' : 'N';
        this.RouteLate = 'Y'; // todo
        this.LastComplaint = (latestComplaintDate != null) ? latestComplaintDate.format() : null;
        this.ExistingComplaint = (latestComplaintDate != null && latestComplaintDate == Date.today()) ? 'Y' : 'N';
        this.ExcessiveComplaint = deliverySchedule.hasEscalatedCases() ? 'Y' : 'N';
        this.Cutoff = deliverySchedule.getTodayCutoffTime();
    }
}