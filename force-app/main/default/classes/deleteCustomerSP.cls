global class deleteCustomerSP implements Database.Batchable<sObject>{
    global final String Query;
    global deleteCustomerSP(String q){
        Query=q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        Datetime cdate = Date.Today();
        cdate.addHours(-4);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC,List<C1ASCloudConnectorConfig__c> scope){
        delete scope;
    }

    global void finish(Database.BatchableContext BC){}
}