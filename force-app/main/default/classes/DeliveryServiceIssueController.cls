public class DeliveryServiceIssueController {
    @AuraEnabled
    public static List<Offer_Product__c> fetchOfferProducts(Id subId) {
        Subscription__c sub = [SELECT Id, subscription_Offer__c FROM Subscription__c WHERE Id = :subId];
        return [SELECT Id, Name FROM Offer_Product__c WHERE Offer__c = :sub.subscription_Offer__c AND Is_Digital__c = FALSE];
    }

    @AuraEnabled 
    public static Id getSubscriptionId(String sObjectType, Id recordId){
        if(sObjectType.equals('Account')){
            List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c WHERE subscription_Account__c = :recordId AND subscription_Status__c = 'Active'];
            if(!subscriptions.isEmpty()) return subscriptions[0].Id;
        }
        if(sObjectType.equals('Case')){
            List<Case> caseAccount = [SELECT AccountId FROM Case WHERE Id = :recordId LIMIT 1];
            if(!caseAccount.isEmpty()){
                List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c WHERE subscription_Account__c = :caseAccount[0].AccountId AND subscription_Status__c = 'Active'];
           		if(!subscriptions.isEmpty()) 
                    return subscriptions[0].Id;
            }   
        }
        if(sObjectType.equals('Subscription__c')){
            return recordId;  
        }
        return null;	        
    }

    @AuraEnabled 
    public static String getLatestExpireDate(Id subscriptionId, String firstDate){
        Date convFirstDate = Date.valueOf(firstDate);
        List<Transaction_Log__c> transLogComplaint = [SELECT Id, Expire_Date__c 
                                    FROM Transaction_Log__c 
                                    WHERE Subscription__c = :subscriptionId AND First_Date__c = :convFirstDate
                                    AND category__c = 'Complaint' ORDER BY LastModifiedDate DESC LIMIT 1];

        if(!transLogComplaint.isEmpty()) {
            String strExpDate = transLogComplaint[0].Expire_Date__c.format();
            return strExpDate;
        }

        return '';
    }    

    @AuraEnabled
    public static Boolean validateDeliveryDate(Id subscriptionId, String selectedDate){
        Boolean result = false;
        
        DateTime dateToValidate = (DateTime) Date.valueOf(selectedDate);
       	Date dateObjToValidate = Date.valueOf(selectedDate);
        dateToValidate = dateToValidate.addHours(12);
        String dayOfWeekSelected = dateToValidate.format('EEEE');
        List<Delivery_Schedule__c> relatedSchedules = [SELECT Day_Friday__c, Day_Monday__c, Day_Saturday__c, Day_Sunday__c, Day_Thursday__c, Day_Tuesday__c, Day_Wednesday__c, Id
                                                       FROM Delivery_Schedule__c
                                                      WHERE subscription_Subscription__c = :subscriptionId AND Start_Date__c <= :dateObjToValidate AND End_Date__c >= :dateObjToValidate];
        for(Delivery_Schedule__c schedule : relatedSchedules){
            System.debug(schedule);
            if(dayOfWeekSelected == 'Sunday' && schedule.Day_Sunday__c){
                result = true;
            }
            else if(dayOfWeekSelected == 'Monday' && schedule.Day_Monday__c){
                result = true;
            }
            else if(dayOfWeekSelected == 'Tuesday' && schedule.Day_Tuesday__c){
                result = true;
            }
            else if(dayOfWeekSelected == 'Wednesday' && schedule.Day_Wednesday__c){
                result = true;
            }
            else if(dayOfWeekSelected == 'Thursday' && schedule.Day_Thursday__c){

                result = true;
            }
            else if(dayOfWeekSelected == 'Friday' && schedule.Day_Friday__c){
                result = true;
            }
            else if(dayOfWeekSelected == 'Saturday' && schedule.Day_Saturday__c){
				result = true;                
            }
        }
        return result;
    }

    @AuraEnabled
    public static void InsertTransaction(Id subscriptionId, Id transactionTypeId, String serviceIssue, String request, String selectedDate, List<Id> selectedOfferProducts, String memo){
        Id oldTransTypeId = transactionTypeId;
        Date convertedDate = Date.valueOf(selectedDate);
        Transaction_Type__c communityCutOffTransType = CutOffManager.communityDeliveryHelper(transactionTypeId, convertedDate);
        transactionTypeId = communityCutOffTransType == null ? transactionTypeId : communityCutOffTransType.Id;
        Id newTransTypeId = transactionTypeId;

        if(oldTransTypeId != newTransTypeId){
            memo += ' - ' + [SELECT Name from Transaction_Type__c WHERE Id = :oldTransTypeId LIMIT 1].Name; 
        } 
        Transaction_Type__c transType = [
            SELECT Id, Name, Code__c, Type_Name__c, Category__c 
            FROM Transaction_Type__c 
            WHERE Id = :transactionTypeId];

        Boolean requestRedelivery = isRedelivery(request, serviceIssue);
        //Id transactionTypeId = getTransactionTypeId(request, serviceIssue);
        Id accountId = [SELECT subscription_Account__c FROM Subscription__c WHERE Id = :subscriptionId LIMIT 1].subscription_Account__c;
        List<Transaction_Log__c> existingTLs;
        if(transType.category__c == 'Complaint'){
            existingTLs = [SELECT Id, First_Date__c, Category__c 
                FROM Transaction_Log__c 
                WHERE Subscription__c = :subscriptionId 
                    AND Transaction_Type__c = :transactionTypeId
                    AND category__c = 'Complaint'
                    AND First_Date__c = :convertedDate];
            if(existingTLs.size() > 0){
                throw new AuraHandledException('A delivery complaint already exists on this day.');
            }
        }
        
        for (Id offerProductId : selectedOfferProducts) {
            TransactionLogHandler.InsertComplaint(subscriptionId, accountId, transactionTypeId, offerProductId, convertedDate, requestRedelivery, memo);
        }
	}



    @AuraEnabled
    public static void createDeliveryIssue(Id subscriptionId, String serviceIssue, String request, Date selectedDate){
        Boolean requestRedelivery = isRedelivery(request, serviceIssue);
        Id transactionTypeId = getTransactionTypeId(request, serviceIssue);
        Id accountId = [SELECT subscription_Account__c FROM Subscription__c WHERE Id = :subscriptionId LIMIT 1].subscription_Account__c;
        
        Transaction_Log__c transactionLog = new Transaction_Log__c();
		transactionLog.Date__c = selectedDate;
		transactionLog.Transaction_Type__c = transactionTypeId;
		transactionLog.Subscription__c = subscriptionId;
		transactionLog.Account__c = accountId;
		transactionLog.Redelivery_Requested__c = requestRedelivery;
        if(!Test.isRunningTest())
		insert transactionLog;
	}

    @AuraEnabled
    public static List<Transaction_Type__c> getDeliveryIssueList(String selectedDate){
        Boolean community = false;
        if(UserInfo.getUserType() != 'Standard'){
            community = true;
        }
        System.debug(UserInfo.getUserType() + '...' + community);

		Date currentDate = Date.today();
        // convert selected date string to date
        Date convertedDate = Date.valueOf(selectedDate);
		
        // Redelivery cutoff
        String whenToDisplayClause = 'AND (When_to_Display__c = \'Anytime\' OR When_to_Display__c = \'After cut-off\') ';
        Boolean beforeCutOff = false;
		if (currentDate == convertedDate && CutOffManager.isBeforeCutOff('Re-delivery')) {
            whenToDisplayClause = 'AND (When_to_Display__c = \'Anytime\' OR When_to_Display__c = \'Before cut-off\') ';
		}
                        
        // based on selected date, returns {Weekday, Saturday, Sunday}
        String DeliveryDayType = CutOffManager.DeliveryDayType(convertedDate);
        // delivery day type clause
        String strDelDayTypeClause = 'AND (Delivery_Day_Type__c = \'All\' OR Delivery_Day_Type__c = \'' + DeliveryDayType + '\') ';

        String communityOnlyClause = '';
        if(community == true){
            communityOnlyClause = 'AND Use_in_Self_Serve_Portal__c = true ';
        }

        // head query string
        String query = 'SELECT Id, Name, Type_Complaint__c, Code__c, Apply_Credit_to_Subscription__c, Redeliver__c ';
        query += 'FROM Transaction_Type__c WHERE Use_in_Flows__c = true AND When_to_Display__c != null ';

        query += strDelDayTypeClause;
        query += whenToDisplayClause;
        query += communityOnlyClause;
        query += 'ORDER BY Name';
        system.debug('--query: ' + query);

        // query result and return list
        List<Transaction_Type__c> ttypeList = Database.query(query);
        return ttypeList;
    }

    private static String getTransactionTypeId(String request, String serviceIssue) {
        String transactionTypeName = null;
        if(request == 'Delivery' && serviceIssue == 'Missed Delivery'){
            transactionTypeName = 'Redelivery Today\'s Missing Newspaper';
        }
        else if(request == 'Delivery' && serviceIssue == 'Wet Paper'){
            transactionTypeName = 'Replace Wet Newspaper';
        }
        else if(request == 'Delivery' && serviceIssue == 'Damaged Paper'){
            transactionTypeName = 'Replaced Damaged Paper';
        }
        else if(request == 'Credit' && serviceIssue == 'Missed Delivery'){
            transactionTypeName = 'Credit for Missed Newspaper';
        }
        else if(request == 'Credit' && serviceIssue == 'Wet Paper'){
            transactionTypeName = 'Credit for Wet Newspaper';
        }
        else if(request == 'Credit' && serviceIssue == 'Damaged Paper'){
            transactionTypeName = 'Credit for Damaged';
        }

        if (String.isNotEmpty(transactionTypeName)) {
            List<Transaction_Type__c> transactionTypes = [SELECT Id from Transaction_Type__c WHERE Name = :transactionTypeName LIMIT 1];
            if(!transactionTypes.isEmpty()){
                return transactionTypes[0].Id;
            }
        }
        return null;
    }

    private static Boolean isRedelivery(String request, String serviceIssue) {
        if(request == 'Delivery' && (serviceIssue == 'Missed Delivery' || serviceIssue == 'Wet Paper') || serviceIssue == 'Damaged Paper'){
            return true;
        }
        return false;
    }

}