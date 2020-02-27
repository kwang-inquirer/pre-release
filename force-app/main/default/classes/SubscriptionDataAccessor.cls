public class SubscriptionDataAccessor  {
	public static Subscription__c getSubscription(String subId) {
		return [
			SELECT Id, Auto_Renew_Tip__c, subscription_Auto_Renew__c, subscription_Status__c
			FROM Subscription__c
			WHERE Id = :subId	
		];
	}

	public static Subscription__c getSubscriptionById(String subId) {
		return [
            SELECT Id, Contact__c, subscription_Account__c, subscription_Status__c, subscription_Offer__c, Subscription_Amount__c, SignatureURL__c, 
				SignatureAttachmentURL__c, subscription_Expired_At__c, Waive_Activation_Fee__c, Renewal_Amount__c, Piano_Target_Id__c, 
				subscription_Current_Period_Started_At__c, subscription_Current_Period_Ends_At__c, Sunday__c, Monday__c, Tuesday__c, Wednesday__c, 
				Thursday__c, Friday__c, Saturday__c, Auto_Renew_Tip__c, subscription_Auto_Renew__c, Number_of_Active_Delivery_Schedules__c, 
				Contact__r.FirstName, Contact__r.LastName, Expire_Balance__c, Outstanding_Credit__c, Expires_On__c, Ready_for_DSI__c, 
				subscription_Account__r.BillingStreet, subscription_Account__r.BillingCity, subscription_Account__r.BillingState,
				subscription_Account__r.BillingCountry, subscription_Account__r.BillingPostalCode,  subscription_Offer__r.Free_Trial__c,
				(SELECT Id, Delivery_Address__c, Delivery_Address__r.Id, Delivery_Address__r.Address_Full_Street__c, Delivery_Address__r.Address_House__c, 
					Delivery_Address__r.Address_City__c, Delivery_Address__r.Pre_Direction__c, Delivery_Address__r.Address_Street__c, 
					Delivery_Address__r.Post_Direction__c, Delivery_Address__r.Address_State__c, Delivery_Address__r.Zip__c, Delivery_Address__r.Unit__c, 
					Delivery_Address__r.Route_Number__c, Offer_Product__r.Per_Copy_Sunday__c, Offer_Product__r.Per_Copy__c, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c,
					Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c, Start_Date__c, End_Date__c, Offer_Product__r.Product__c
					FROM Delivery_Schedules__r WHERE Status__c = 'Active' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Offer_Product__c != NULL),
				(SELECT Id, recurly_v2__Card_Type__c, recurly_v2__Last_Four__c, recurly_v2__Code__c FROM Recurly_Accounts__r)
            FROM Subscription__c
            WHERE Id = :subId
        ];
	}

	public static List<Subscription__c> getSubscriptionsByEmail(String email) {
		return  [ 
			SELECT Id, Contact__c, subscription_Account__c, subscription_Status__c, subscription_Offer__c, Subscription_Amount__c, SignatureURL__c, 
				SignatureAttachmentURL__c, subscription_Expired_At__c, Waive_Activation_Fee__c, Renewal_Amount__c, Piano_Target_Id__c, 
				subscription_Current_Period_Started_At__c, subscription_Current_Period_Ends_At__c, Sunday__c, Monday__c, Tuesday__c, Wednesday__c, 
				Thursday__c, Friday__c, Saturday__c, Auto_Renew_Tip__c, subscription_Auto_Renew__c, Number_of_Active_Delivery_Schedules__c, 
				Contact__r.FirstName, Contact__r.LastName, Expire_Balance__c, Outstanding_Credit__c, Expires_On__c, Ready_for_DSI__c, 
				subscription_Account__r.BillingStreet, subscription_Account__r.BillingCity, subscription_Account__r.BillingState,
				subscription_Account__r.BillingCountry, subscription_Account__r.BillingPostalCode, subscription_Offer__r.Free_Trial__c,
				(SELECT Id, Delivery_Address__c, Delivery_Address__r.Id, Delivery_Address__r.Address_Full_Street__c, Delivery_Address__r.Address_House__c, 
					Delivery_Address__r.Address_City__c, Delivery_Address__r.Pre_Direction__c, Delivery_Address__r.Address_Street__c, 
					Delivery_Address__r.Post_Direction__c, Delivery_Address__r.Address_State__c, Delivery_Address__r.Zip__c, Delivery_Address__r.Unit__c, 
					Delivery_Address__r.Route_Number__c, Offer_Product__r.Per_Copy_Sunday__c, Offer_Product__r.Per_Copy__c, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c,
					Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c, Start_Date__c, End_Date__c, Offer_Product__r.Product__c
					FROM Delivery_Schedules__r WHERE Status__c = 'Active' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Offer_Product__c != NULL),
				(SELECT Id, recurly_v2__Card_Type__c, recurly_v2__Last_Four__c, recurly_v2__Code__c FROM Recurly_Accounts__r)
			FROM Subscription__c 
			WHERE Contact__r.Email = :email
			ORDER BY CreatedDate DESC
		];
	}

/*
	public static List<Subscription__c> getSubscriptionsByOfferEmail(Id offerId, String email) {
		return  [ 
			SELECT Id, Contact__c, subscription_Account__c, subscription_Status__c, subscription_Offer__c, Subscription_Amount__c, SignatureURL__c, 
				SignatureAttachmentURL__c, subscription_Expired_At__c, Waive_Activation_Fee__c, Renewal_Amount__c, Piano_Target_Id__c, 
				subscription_Current_Period_Started_At__c, subscription_Current_Period_Ends_At__c, Sunday__c, Monday__c, Tuesday__c, Wednesday__c, 
				Thursday__c, Friday__c, Saturday__c, Auto_Renew_Tip__c, subscription_Auto_Renew__c, Number_of_Active_Delivery_Schedules__c, 
				Contact__r.FirstName, Contact__r.LastName, Expire_Balance__c, Outstanding_Credit__c, Expires_On__c, Ready_for_DSI__c, 
				subscription_Account__r.BillingStreet, subscription_Account__r.BillingCity, subscription_Account__r.BillingState, subscription_Next_Bill_Date__c, 
				subscription_Account__r.BillingCountry, subscription_Account__r.BillingPostalCode, subscription_Offer__r.Free_Trial__c,
				(SELECT Id, Delivery_Address__c, Delivery_Address__r.Id, Delivery_Address__r.Address_Full_Street__c, Delivery_Address__r.Address_House__c, 
					Delivery_Address__r.Address_City__c, Delivery_Address__r.Pre_Direction__c, Delivery_Address__r.Address_Street__c, 
					Delivery_Address__r.Post_Direction__c, Delivery_Address__r.Address_State__c, Delivery_Address__r.Zip__c, Delivery_Address__r.Unit__c, 
					Delivery_Address__r.Route_Number__c, Offer_Product__r.Per_Copy_Sunday__c, Offer_Product__r.Per_Copy__c, Day_Sunday__c, Day_Monday__c, Day_Tuesday__c,
					Day_Wednesday__c, Day_Thursday__c, Day_Friday__c, Day_Saturday__c, Start_Date__c, End_Date__c, Offer_Product__r.Product__c
					FROM Delivery_Schedules__r WHERE Status__c = 'Active' AND Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Offer_Product__c != NULL),
				(SELECT Id, recurly_v2__Card_Type__c, recurly_v2__Last_Four__c, recurly_v2__Code__c FROM Recurly_Accounts__r)
			FROM Subscription__c 
			WHERE subscription_Offer__c = :offerId
			AND Contact__r.Email = :email
		];
	}
*/
}