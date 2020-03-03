public class CutOffManager  {

	public CutOffManager(){}

	@InvocableMethod
	public static List<Boolean> isBeforeCutOff(List<String> CutOffType){
		List<Boolean> booResult = new List<Boolean>();
		for(String str: CutOffType){
			booResult.add(isBefore(str));
		}
		return booResult;
	}
	public static Boolean isBeforeCutOff(String CutOffType){
		Boolean booResult = false;
		booResult = isBefore(CutOffType);
		return booResult;
	}
	
	public static String DeliveryDayType(Date selectedDate){
		// based on selected date input, returns {Weekday, Saturday, Sunday}
		String result = '';
		String CutOffType = 'Re-delivery';  //default CutOffType

        Datetime selectedDT = datetime.newInstance(selectedDate.year(), selectedDate.month(),selectedDate.day());
		// system.debug('--DeliveryDayType--selectedDate: '+ selectedDate);
		// system.debug('--DeliveryDayType--DayOfWeek   : '+ selectedDT.format('EEEE'));

		// get the record
		Cut_Offs_Time__mdt cot = [SELECT Delivery_Type__c 
					FROM Cut_Offs_Time__mdt 
					WHERE Day_of_Week__c =: selectedDT.format('EEEE')
					AND Cut_Off_Type__c =: CutOffType];
		
		system.debug('--DeliveryDayType returned: ' + cot.Delivery_Type__c );
		result = cot.Delivery_Type__c;
		return result;
	}

	private static Boolean isBefore(String CutOffType){
		Boolean booResult = false;
		
		// get current day and time
		Datetime currDateTime = Datetime.now();
		// get the cut-off record
		Cut_Offs_Time__mdt co = [SELECT Hour__c, Minute__c, Community_Redeliver__c
					FROM Cut_Offs_Time__mdt 
					WHERE Day_of_Week__c =: currDateTime.format('EEEE')
					AND Cut_Off_Type__c =: CutOffType];
		// compare date
		booResult = currDateTime.time() < Time.newInstance(Integer.valueOf(co.Hour__c), Integer.valueOf(co.Minute__c), 0, 0);
		Boolean communityRedelivery = (UserInfo.getUserType() != 'Standard' &&  co.Community_Redeliver__c && CutOffType == 'Re-delivery');
		return booResult || communityRedelivery;
	}

	public static Transaction_Type__c communityDeliveryHelper(Id transactionTypeId, Date transactionDate){
        Date currentDate = Date.today();
		DateTime transDateDT = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 12, 0, 0);
		/* Check CMT for Community_Redeliver__c flag and user type. */
		Cut_Offs_Time__mdt co = [SELECT Community_Redeliver__c
				FROM Cut_Offs_Time__mdt 
				WHERE Day_of_Week__c =: transDateDT.format('EEEE')
				AND Cut_Off_Type__c =: 'Re-delivery'];
				System.debug('co: ' + co);

		if(UserInfo.getUserType() == 'Standard' || !co.Community_Redeliver__c)
			return null;
        /*Verify current day is selected*/
        if(currentDate != transactionDate) 
			return null;
		List<Transaction_Type__c> transTypeList = [SELECT Id, Name, Code__c, Type_Name__c, Category__c, Redeliver__c
            FROM Transaction_Type__c 
            WHERE Code__c = 'NE' OR Code__c = 'CM' OR Id = :transactionTypeId];
		
		Transaction_Type__c nextDayRecovery;
		Transaction_Type__c missingManufacturerCoupons;
		Transaction_Type__c oldTransType;
		for(Transaction_Type__c tt : transTypeList){
			if(tt.Code__c == 'NE')
				nextDayRecovery = tt;
			if(tt.Code__c == 'CM')
				missingManufacturerCoupons = tt;
			if(tt.Id == transactionTypeId)
				oldTransType = tt;
		}
		if(oldTransType.Name == 'Missing Manufacturer Coupons'){
			return missingManufacturerCoupons;
		}    
		else{
			if(!oldTransType.Redeliver__c)
				return null;
			return nextDayRecovery;
		} 
    }
}