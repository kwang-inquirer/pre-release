global class DeleteComplaints implements Database.Batchable<SObject> {
	global DeleteComplaints() {
	}
	
	global Database.QueryLocator start(Database.BatchableContext context) {
		String dsQuery = 'SELECT Subscription__c, SFID__c FROM Account';
		return Database.getQueryLocator(dsQuery);
	}

   	global void execute(Database.BatchableContext context, List<Account> scope) {
		System.debug('Scope size: ' + scope.size());
		//Database.deleteImmediate(scope);
	}
	
	global void finish(Database.BatchableContext context) {
		
	}
}