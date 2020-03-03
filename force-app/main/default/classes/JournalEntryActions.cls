public class JournalEntryActions  {

    @AuraEnabled
    public static List<SuperJournalEntry> PullJournalEntries(String sobjId, String filterType){
        System.debug('the type filter is: ' + filterType);
        if(filterType == 'none' || filterType == null || String.isBlank(filterType)) {filterType = '%';}
        // get the type of Id sent
        Schema.SObjectType token = Id.valueOf(sobjId).getSobjectType();
        Schema.DescribeSObjectResult dr = token.getDescribe();
        // Pull the correct logs
        List<SuperJournalEntry> journalEntries = new List<SuperJournalEntry>();
        if(dr.getName() == 'Subscription__c'){
            journalEntries = getSubscriptionjournalEntries(sobjId, filterType);
        }
		journalEntries.sort();
        return journalEntries;
    }

    public static List<SuperJournalEntry> getSubscriptionjournalEntries(String subscriptionId, String filterType){
        List<SuperJournalEntry> lstResult = new List<SuperJournalEntry>();
        List<string> filterList = filterType.split(',');
        // add sObjects
        lstResult.addAll(JournalEntryActions.addSObjects(subscriptionId,filterList));
        // add big objects
        lstResult.addAll(JournalEntryActions.addBOJournalEntries(subscriptionId));
		lstResult.addAll(JournalEntryActions.addBORecurlyPayments(subscriptionId));
        // add TransactionComplaint BO
        return lstResult;
    }


    private static List<SuperJournalEntry> addSObjects(Id subId, List<string> FilterList){
        List<SuperJournalEntry> lstResult = new List<SuperJournalEntry>();
        List<Journal__c> pulledJE = [SELECT
                Credit__c,
                Debit__c,
                Description__c,
                Entry_Date__c,
                Entry_Type__c
            FROM Journal__c
            WHERE Subscription__c =: subId
            Limit 1000];
        for(Journal__c thisJE: pulledJE){
            SuperJournalEntry superJE = new SuperJournalEntry();
            superJE.Debit = thisJE.Debit__c;
			superJE.Credit = thisJE.Credit__c;
			superJE.EntryDate = thisJE.Entry_Date__c;
			superJE.EntryType = thisJE.Entry_Type__c;
			superJE.Description = thisJE.Description__c;
			superJE.Source = 'Journal';
            lstResult.add(superJE);
        }
        return lstResult;
    }
    private static List<SuperJournalEntry> addBOJournalEntries(Id subId){
        List<SuperJournalEntry> lstResult = new List<SuperJournalEntry>();
        //List<Journal_Entry__b> pulledJE = [SELECT
                //Credit__c,
                //Debit__c,
                //Description__c,
                //Entry_Date__c,
                //Entry_Type__c
            //FROM Journal_Entry__b
            //WHERE Subscription__c =: subId
            //Limit 1000];
        //for(Journal_Entry__b thisJE: pulledJE){
            //SuperJournalEntry superJE = new SuperJournalEntry();
            //superJE.Debit = thisJE.Debit__c;
			//superJE.Credit = thisJE.Credit__c;
			//superJE.EntryDate = thisJE.Entry_Date__c.date();
			//superJE.EntryType = thisJE.Entry_Type__c;
			//superJE.Description = thisJE.Description__c;
			//superJE.Source = 'Journal';

            //lstResult.add(superJE);
        //}
        return lstResult;
    }
    private static List<SuperJournalEntry> addBORecurlyPayments(Id subId){
        List<SuperJournalEntry> lstResult = new List<SuperJournalEntry>();
        //List<ReCurly_Transaction__b> pulledJE = [SELECT
				//Check_Number__c,
				//recurly_Amount__c,
				//recurly_Collected_At__c,
				//recurly_Payment_Card_Type__c,
				//recurly_Payment_Last_Four__c
			//FROM ReCurly_Transaction__b
            //WHERE Subscription__c =: subId
            //Limit 1000];
        //for(ReCurly_Transaction__b thisJE: pulledJE){
            //SuperJournalEntry superJE = new SuperJournalEntry();
			//if(thisJE.recurly_Amount__c>0){
				//superJE.Credit = thisJE.recurly_Amount__c;
			//}else{
				//superJE.Debit = -thisJE.recurly_Amount__c;				
			//}
			//superJE.EntryDate = thisJE.recurly_Collected_At__c.date();
			//superJE.EntryType = 'CC Payment';
			//superJE.Description = thisJE.recurly_Payment_Card_Type__c;
			//superJE.Source = 'Credit Card';
            //lstResult.add(superJE);
        //}
        return lstResult;
    }


    public class SuperJournalEntry implements Comparable{
        @AuraEnabled public double Debit {get;set;}
        @AuraEnabled public double Credit {get;set;}
        @AuraEnabled public String Description {get;set;}
        @AuraEnabled public Date EntryDate {get;set;}
        @AuraEnabled public String EntryType {get;set;}
        @AuraEnabled public String Source {get;set;}
				

		public Integer compareTo(Object compareTo){
			Integer intResult = 1;
			SuperJournalEntry st = (SuperJournalEntry)compareTo;
			if(EntryDate == st.EntryDate) intResult = 0;
			if(EntryDate > st.EntryDate) intResult = -1;
			return intResult;	
		}
    }
}