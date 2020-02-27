global class PressRunSync implements Database.Batchable<SObject> {
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String query = 'SELECT Id, Outstanding_Credit__c, Total_Liability__c FROM Subscription__c WHERE subscription_Status__c = \'Active\'';
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext context, List<Subscription__c> scope) {
		List<Subscription__c> subsToUpdate = new List<Subscription__c>();
        for(Subscription__c sub : scope){
            if(sub.Outstanding_Credit__c != sub.Total_Liability__c){
                subsToUpdate.add(
                    new Subscription__c(
                        Id = sub.Id,
                        Total_Liability__c = sub.Outstanding_Credit__c
                    )
                );
            }
        }
		if(!subsToUpdate.isEmpty()){}
			update subsToUpdate;
	}
	
	global void finish(Database.BatchableContext context) {
		PressRunProcess b = new PressRunProcess();
        database.executebatch(b);
	}
}