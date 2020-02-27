public class ServiceInfo {
    public String Account {get;set;}
    public String ProductName {get;set;}
    public String ServiceType {get;set;}
    public String AllowComplaints {get;set;}
    public String ReDeliverableRoute {get;set;}
    public String RouteLate {get;set;}
    public String LastComplaint {get;set;}
    public String ExistingComplaint {get;set;}
    public String ExcessiveComplaint {get;set;}
    public String Cutoff {get;set;}

    private transient DeliverySchedule deliverySchedule;

    public ServiceInfo(Delivery_Schedule__c schedule) {
        this.deliverySchedule = new DeliverySchedule(schedule);

        Transaction_Log__c latestComplaint = deliverySchedule.getLastestComplaint();
        Date latestComplaintDate = latestComplaint != null ? latestComplaint.Date__c : null;

        this.Account = schedule.subscription_Subscription__r.subscription_Account__c;
        this.ProductName = schedule.Offer_Product__r.Name;
        this.ServiceType = deliverySchedule.getScheduleForWeek();
        // check value from Route linked to the Delivery schedule
        this.AllowComplaints = (schedule.Routelookup__r.Complaints_Allowed__c) ? 'Y' : 'N';
        // check value from Route linked to the Delivery schedule
        this.ReDeliverableRoute = (schedule.Routelookup__r.Redelivery_Allowed__c) ? 'Y' : 'N';

        // check conditions to set RouteLate output parameter
        String txtDistrict = schedule.Routelookup__r.District__c;
        List<Route_Delay__c> rtDelayDistricts = [SELECT Id, District_From__c,District_Until__c FROM Route_Delay__c 
                                                WHERE (District_From__c = :txtDistrict OR District_Until__c = :txtDistrict) 
                                                AND District_Match__c = true];
        Boolean rtDistFlag = !rtDelayDistricts.isEmpty();
        
        Boolean rtRouteNumFlag = deliverySchedule.hasRouteNumInRange();
        Boolean rtLateCheck = deliverySchedule.hasRouteDelayRec() || rtDistFlag || rtRouteNumFlag;
        this.RouteLate = rtLateCheck ? 'Y' : 'N';

        this.LastComplaint = (latestComplaintDate != null) ? latestComplaintDate.format() : null;
        this.ExistingComplaint = (latestComplaintDate != null && latestComplaintDate == Date.today()) ? 'Y' : 'N';
        this.ExcessiveComplaint = deliverySchedule.hasEscalatedCases() ? 'Y' : 'N';
        this.Cutoff = deliverySchedule.getTodayCutoffTime();
    }
}