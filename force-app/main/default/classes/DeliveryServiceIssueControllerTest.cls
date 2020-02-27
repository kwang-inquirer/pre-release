@isTest
private class DeliveryServiceIssueControllerTest {
    @isTest static void shouldValidateDeliveryDate(){

                List<Product2> lstPub = new List<Product2>();
        List<Offer__c> lstOffer = new List<Offer__c>();
        List<Offer_Product__c> lstOffProd = new List<Offer_Product__c>();
		//
		// Create Foundational Records
		//
		for(Integer i = 0; i<4; i++){
			Product2 pub = new Product2();
			if(i == 0){
				pub.Name = 'Philadelphia Inquirer';
				pub.ProductCode = '1';
				pub.IsDigital__c = false;

			}
			if(i == 1){
				pub.Name = 'Daily News';
				pub.ProductCode = '2';
				pub.IsDigital__c = false;
			}
			if(i == 2){
				pub.Name = 'Meter All Digital Add On';
				pub.ProductCode = '50';
				pub.IsDigital__c = true;
			}
			if(i == 3){
				pub.Name = 'All Digital Metered';
				pub.ProductCode = '150';
				pub.IsDigital__c = true;
			}
			lstPub.add(pub);
		}
		insert lstPub;

		for(Integer i = 0; i<3; i++){
			Offer__c off = new Offer__c();
			off.Name = 'Test ' + i;
			off.Number_of_Weeks__c = i*4;
			lstOffer.add(off);
            insert lstOffer;
			lstOffProd = new List<Offer_Product__c>();
			for(Integer x = 0; i<2; i++){
				Offer_Product__c op = new Offer_Product__c();
				if(x == 0){
					op.Product__c = lstPub[0].Id;
					op.Per_Copy__c = .50;
					op.Per_Copy_Sunday__c = 1.5;
					op.Offer__c = off.Id;
				}
				if(x == 1){
					op.Product__c = lstPub[2].Id;
					op.Per_Copy__c = .50;
					op.Per_Copy_Sunday__c = 1.5;
					op.Offer__c = off.Id;
				}
				lstOffProd.add(op);
			}
		}
		
		insert lstOffProd;

        Account account = new Account(
            Name = 'RelationEdge');
        insert account;
        Subscription__c subscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdge',
            Delivery_Instructions__c = 'Throw it at the front door.',
            Outstanding_Credit__c = 20.25,
            subscription_Status__c = 'Active',
            subscription_Offer__c = lstOffProd[0].Offer__c
        );
        Case caseToInsert = new Case();
        caseToInsert.AccountId = account.Id;
        insert caseToInsert;
        insert subscription;


        Transaction_Type__c tt = new Transaction_Type__c();
        tt.Name = 'Redelivery Today\'s Missing Newspaper';
        insert tt;
        Transaction_Type__c tt2 = new Transaction_Type__c();
        tt2.Name = 'Replace Wet Newspaper';
        insert tt2;
        Transaction_Type__c tt3 = new Transaction_Type__c();
        tt3.Name = 'Replaced Damaged Paper';
        insert tt3;
        Transaction_Type__c tt4 = new Transaction_Type__c();
        tt4.Name = 'Credit for Missed Newspaper';
        insert tt4;
        Transaction_Type__c tt5 = new Transaction_Type__c();
        tt5.Name = 'Credit for Wet Newspaper';
        insert tt5;
        Transaction_Type__c tt6 = new Transaction_Type__c();
        tt6.Name = 'Credit for Damaged';
        insert tt6;
        Delivery_Schedule__c schedule = new Delivery_Schedule__c(
            subscription_Subscription__c = subscription.Id,
            Start_Date__c = date.newInstance(2019, 1, 1),
            End_Date__c = date.newInstance(2019, 1, 7),
            Day_Wednesday__c = true,
            Day_Tuesday__c = true,
            Day_Monday__c = true,
            Day_Sunday__c = true,
            Day_Thursday__c = true,
            Day_Friday__c = true,
            Day_Saturday__c = true
        );
        insert schedule;
        List<String> stringDates = new List<String>();
        for(integer i = 1; i < 7; ++i){
            DeliveryServiceIssueController.validateDeliveryDate(subscription.Id, '2019-1-' + i);
        }
        DeliveryServiceIssueController.fetchOfferProducts(subscription.Id);
        DeliveryServiceIssueController.getSubscriptionId('Account', account.Id);
        DeliveryServiceIssueController.getLatestExpireDate(subscription.Id, '2019-1-30');
        DeliveryServiceIssueController.createDeliveryIssue(subscription.Id, 'Damaged Paper', 'Credit', Date.today());

    }

    @isTest static void shouldRedeliveryCommunity(){
        TestDataFactory.createTestRecords(3);
        Date currentDate = Date.today();
		DateTime transDateDT = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 12, 0, 0);
        
       Account a = new Account(Name='Test Account Name');
        insert a;
        
        Contact c = new Contact(LastName = 'Contact Last Name', AccountId = a.id);
        insert c;
        
        User user = new User();
        user.ProfileID = [Select Id From Profile Where Name='Subscriber Community'].id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@test.com';   
        user.CommunityNickname = 'testUser123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = c.Id;
        
        insert user;
        //system.runAs(user) {
            List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c];
            List<Offer_Product__c> offProducts = [SELECT Id FROM Offer_Product__c LIMIT 3];
            List<Id> offerProductIds = new List<Id>();
            for(Offer_Product__c offProduct :DeliveryServiceIssueController.fetchOfferProducts(subscriptions[0].Id)){
                offerProductIds.add(offProduct.Id);
            }
            Transaction_Type__c transType = [
                SELECT Id 
                FROM Transaction_Type__c 
                WHERE Code__c = 'DD' LIMIT 1
            ];
            CutOffManager.communityDeliveryHelper(transType.Id, currentDate);
            DeliveryServiceIssueController.InsertTransaction(subscriptions[0].Id, transType.Id, 'ServiceIssue', 'Request', '2020-1-20',  offerProductIds, 'memo');
            List<Transaction_Type__c> result = DeliveryServiceIssueController.getDeliveryIssueList('2020-1-20');
        }       
    //}   
}