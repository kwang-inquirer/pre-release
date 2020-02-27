@isTest
public class TestDataFactory {
    public static void createTestRecords(Integer numRecords) {
        createAccounts(numRecords);
        createContacts(numRecords);
        createProductsAndOffers(numRecords);
        createSubscriptions(numRecords);
        createDeliveryAddresses(numRecords);
        createDeliverySchedules(numRecords);
        createTransactionTypes();
        createCampaignsWithOffers(numRecords);
        createBillings();
        createRecurlyAccounts(numRecords);
        createRoutes();
    }
    public static void createAccounts(Integer numAccts) {
        List<Account> lstAcc = new List<Account>();
        for(Integer i = 0; i<numAccts; i++){
			Account acc = new Account(name = 'Test Household ' + i);
			lstAcc.add(acc);
		}
		insert lstAcc;
    }
    public static void createContacts(Integer numContacts){
        List<Account> accounts = [SELECT Id FROM ACCOUNT LIMIT :numContacts];
        List<Contact> lstCon = new List<Contact>();
        for(Integer i = 0; i<numContacts; i++){
            Contact cont = new Contact();
            cont.FirstName = 'First' + i;
            cont.LastName = 'Last' + i;
            cont.Email = 'test' + i + '@test.com';
            cont.Account = accounts[i];
            lstCon.add(cont);
        }

        insert lstCon;
	}
    public static void createProductsAndOffers(Integer numOffers){
        List<Product2> lstProduct = new List<Product2>();
        List<Offer__c> lstOffer = new List<Offer__c>();
        List<Offer_Product__c> lstOffProd = new List<Offer_Product__c>();

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
			lstProduct.add(pub);
		}
		insert lstProduct;

        for(Integer j = 0; j<numOffers; j++){
            Offer__c off = new Offer__c();
			off.Name = 'Test ' + j;
			off.Number_of_Weeks__c = j*4;
            if(j == 0 )
                off.Free_Trial__c = true;
			lstOffer.add(off);
        }
        insert lstOffer;

        Integer productIndex = 0;
        for(Offer__c off : lstOffer){
            if(productIndex == 4)
                productIndex = 0;
            for(Integer k = 0; k<2; k++){
                Offer_Product__c op = new Offer_Product__c();
                op.Name = 'Offer Product ' + off.Name + String.valueOf(k);
                if(k == 0){
                    op.Product__c = lstProduct[productIndex].Id;
                    op.Per_Copy__c = (k*.50)+.25;
                    op.Per_Copy_Sunday__c = (k*1.5)+.25;
                    op.Offer__c = off.Id;
                    op.Is_Activation_Fee__c = true; 
                    op.Activation_Fee__c = 0.0;
                }
                if(k == 1){
                    op.Product__c = lstProduct[productIndex].Id;
                    op.Per_Copy__c = (k*.50)+.25;
                    op.Per_Copy_Sunday__c = (k*1.5)+.25;
                    op.Offer__c = off.Id;
                    op.Is_Activation_Fee__c = true; 
                    op.Activation_Fee__c = 0.0;
                }
                lstOffProd.add(op);
            }
            ++productIndex;
        }
        insert lstOffProd;
    }
    public static void createSubscriptions(Integer numSubscriptions){
        List<Subscription__c> subLst = new List<Subscription__c>();
        List<Account> accounts = [SELECT Id FROM Account LIMIT :numSubscriptions];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT :numSubscriptions];
        List<Offer__c> offers = [SELECT Id FROM Offer__c LIMIT :numSubscriptions];
        for(Integer i = 0; i<numSubscriptions; i++){
            Subscription__c subscription = new Subscription__c(
                subscription_Account__c = accounts[i].Id,
                subscription_Offer__c = offers[i].Id,
                contact__c = contacts[i].Id,
                Attention_Line__c = 'Attention Line ' + i,
                Delivery_Instructions__c = 'Instructions: ' + i,
                subscription_Current_Period_Ends_At__c = Date.Today().AddDays(60)
            );
            if(i == 1 || i == 3 || i == 5)
                subscription.Pending_Offer__c = offers[i-1].Id;
            subLst.add(subscription);
        }
        insert subLst;
    }
    public static void createDeliveryAddresses(Integer numAddress){
        List<Delivery_Address__c> addressLst = new List<Delivery_Address__c>();
        List<Delivery_Address__c> toUpdate = new List<Delivery_Address__c>();
        for(Integer i = 0; i<numAddress; i++){
            addressLst.add(new Delivery_Address__c(	
                Address_City__c = 'Villanova',
                Zip__c = '19132',
                Address_State__c = 'PA',
                Address_Street__c = '20' +i+ ' W Hagert St',
                Address_House__c = '2425',
                DSI_Id__c = 'TestId' + i));
        }
        insert addressLst;
        for(Delivery_Address__c address : addressLst){
            toUpdate.add(new Delivery_Address__c(
                Id = address.Id,
                Melissa_Response__c = 'AS01'));
        }
        update toUpdate;
    }
    public static void createDeliverySchedules(Integer numSchedules){
        List<Delivery_Schedule__c> scheduleList = new List<Delivery_Schedule__c>();
        List<Subscription__c> subscriptions = [SELECT Id FROM Subscription__c LIMIT :numSchedules];
        List<Delivery_Address__c> addresses = [SELECT Id FROM Delivery_Address__c LIMIT :numSchedules];
        List<Offer_Product__c> offerProducts = [SELECT Id FROM Offer_Product__c LIMIT :numSchedules];
        Boolean evenIndex;
        for(Integer i = 0; i<numSchedules; i++){
            evenIndex = math.mod(i, 2) == 0 ? true : false;
            Delivery_Schedule__c schedule = new Delivery_Schedule__c();
            schedule.subscription_Subscription__c = subscriptions[i].Id;
            schedule.Delivery_Address__c = addresses[i].Id;
            schedule.Day_Monday__c = evenIndex;
            schedule.Day_Tuesday__c = evenIndex;
            schedule.Day_Wednesday__c = evenIndex;
            schedule.Day_Thursday__c = evenIndex;
            schedule.Day_Friday__c = evenIndex;
            schedule.Day_Saturday__c = !evenIndex;
            schedule.Day_Sunday__c = !evenIndex;
            schedule.Start_Date__c = Date.today().addDays(Math.Round(-i/2));
            schedule.End_Date__c = Date.today().addDays(Math.Round(i/2));
            schedule.Offer_Product__c = offerProducts[i].Id;
            schedule.Status__c = 'Active';
            scheduleList.add(schedule);
        }
        insert scheduleList;
    }
    public static void createTransactionTypes(){
        List<Transaction_Type__c> toInsert = new List<Transaction_Type__c>();
        toInsert.add(new Transaction_Type__c(
            Name = 'Credit for Missed Newspaper',
            Type_Name__c = 'Delivery', 
            DSI__c = true, 
            Type_Complaint__c = 'DELC',
            Code__c = 'ND', 
            Category__c = 'Complaint', 
            When_to_Display__c = 'After cut-off'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Replace Wet Newspaper',
            Type_Name__c = 'Delivery', 
            DSI__c = true, 
            Type_Complaint__c = 'DELC',
            Code__c = 'DW', 
            Category__c = 'Complaint', 
            When_to_Display__c = 'Before cut-off'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Credit for Damaged',
            Type_Name__c = 'Delivery', 
            DSI__c = true, 
            Type_Complaint__c = 'DELC',
            Code__c = 'DD', 
            Category__c = 'Complaint',
            Apply_Credit_to_Subscription__c = true, 
            When_to_Display__c = 'After cut-off'));

        toInsert.add(new Transaction_Type__c(
            Name = 'Credit for Damaged',
            Type_Name__c = 'Complaint', 
            DSI__c = true, 
            Type_Complaint__c = 'DELC',
            Code__c = 'DD2', 
            Category__c = 'Complaint',
            Apply_Credit_to_Subscription__c = true, 
            When_to_Display__c = 'After cut-off'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Memo Messages',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            DSI__c = false, 
            Code__c = 'ME'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Vacation Problem-Delivered while away',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            Use_in_Flows__c = true,
            DSI__c = true, 
            Code__c = 'VP', 
            Category__c = 'Complaint', 
            When_to_Display__c = 'Anytime'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Vacation Package',
            Type_Name__c = 'Retention', 
            Type_Complaint__c = 'VAC',
            DSI__c = true, 
            Use_in_Flows__c = true,
            Code__c = 'VPA'
           ));
        toInsert.add(new Transaction_Type__c(
            Name = 'Vacation Hold',
            Type_Name__c = 'Retention', 
            Type_Complaint__c = 'VAC',
            DSI__c = true, 
            Use_in_Flows__c = true,
            Code__c = 'VH'
           ));           
        toInsert.add(new Transaction_Type__c(
            Name = 'Serious Complaint',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            DSI__c = true, 
            Code__c = 'S4',
            Message__c = '* * * SERIOUS COMPLAINT * * *',
            Category__c = 'Complaint', 
            Use_in_Flows__c = true,
            When_to_Display__c = 'Anytime'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Serious Complaint - Unresolved',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            DSI__c = true, 
            Code__c = 'SU',
            Message__c = '** SERIOUS COMPLAINT UNRESOLVED **',
            Category__c = 'Complaint', 
            Use_in_Flows__c = true,
            When_to_Display__c = 'Anytime'));
        toInsert.add(new Transaction_Type__c(
            Name = 'Charge Back',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            DSI__c = false, 
            Code__c = 'CB',
            Message__c = 'CHARGE BACK',
            When_to_Display__c = 'Anytime',
            Use_in_Flows__c = true));
        toInsert.add(new Transaction_Type__c(
            Name = 'Digital Package Opt Out',
            Type_Name__c = 'Retention', 
            Type_Complaint__c = 'RETN',
            DSI__c = false, 
            Code__c = 'DO',
            Message__c = 'Digital Opt Out',
            Category__c = 'Complaint'
        ));
         toInsert.add(new Transaction_Type__c(
            Name = 'Next Day Recovery',
            Type_Name__c = 'COMO', 
            Type_Complaint__c = 'COMO',
            DSI__c = false, 
            Code__c = 'NE',
            Message__c = 'NEXT DAY RECOVERY',
            Category__c = 'Complaint'
        ));
         toInsert.add(new Transaction_Type__c(
            Name = 'Missing Manufacturer Coupons',
            Type_Name__c = 'Misc', 
            Type_Complaint__c = 'MISC',
            DSI__c = false, 
            Code__c = 'CM',
            Message__c = 'MISSING COUPONS',
            Category__c = 'Complaint'
        ));       
        insert toInsert;
    }
    public static void createCampaignsWithOffers(Integer numRecords){
        List<Campaign> campaigns = new List<Campaign>();
        List<Campaign_Offer__c> campaignOffers = new List<Campaign_Offer__c>();
        List<Offer__c> offers = [SELECT Id FROM Offer__c LIMIT :numRecords];
        for(Integer i = 0; i < 10; i++){
            campaigns.add(new Campaign(
                Name = 'Campaign ' + i
            ));
        }
        insert campaigns;
        Integer loopCap = Math.min(9, numRecords);
        for(Integer j = 0; j < loopCap; j++){
            campaignOffers.add(new Campaign_Offer__c(
                Campaign__c = campaigns[j].id,
                Offer__c = offers[j].Id
            ));
        }
        insert campaignOffers;
    }

    public static void createBillings(){
        List<Billing__c> toInsert = new List<Billing__c>();
        for(Subscription__c sub : [SELECT Id FROM Subscription__c]){
            toInsert.add(new Billing__c(
                Amount__c = 1.25,
                Bill_Date__c = Date.today().addDays(-5),
                Term__c = 15,
                Subscription__c = sub.Id
            ));
            toInsert.add(new Billing__c(
                Amount__c = 2.50,
                Bill_Date__c = Date.today(),
                Term__c = 30,
                Subscription__c = sub.Id
            ));
        }
        insert toInsert;
    }
    public static void createRecurlyAccounts(Integer numRecords){
        List<recurly_v2__Recurly_Account__c> toInsert = new List<recurly_v2__Recurly_Account__c>();
        Integer loopCap = Math.min(numRecords, 10);
        List<Account> accList = [SELECT Id FROM Account LIMIT :loopCap]; 
        for(Integer i = 0; i < loopCap; i++){
            toInsert.add(new recurly_v2__Recurly_Account__c(recurly_v2__Account__c = accList[i].Id));
        }
        insert toInsert;
    }
    public static void createRoutes(){
        List<Route__c> routes = new List<Route__c>();
        routes.add(new Route__c(
            Name = '00002000',
            Route_Id__c = '00002000',
            Route_Type__c = 'IS',
            ADI__c = '70',
            Division__c = 'SCS',
            District__c = 'AIN'
        ));
        routes.add(new Route__c(
            Name = '00063000',
            Route_Id__c = '00063000',
            Route_Type__c = 'HC',
            ADI__c = '70',
            Division__c = 'SCS',
            District__c = 'AIN'
        ));

        insert routes;

        List<Route_Street__c> rsList = new List<Route_Street__c>();
        for(Route__c route : routes){
            rsList.add(new Route_Street__c(
                Name = 'RS 1',
                Route__c = route.Id,
                House_Low__c = 100,
                House_High__c = 300,
                Street_Name__c = 'Maple',
                From__c = Date.today(),
                To__c  = Date.today().addDays(10)
            ));
            rsList.add(new Route_Street__c(
                Name = 'RS 2',
                Route__c = route.Id,
                House_Low__c = 200,
                House_High__c = 400,
                Street_Name__c = 'Willow',
                From__c = Date.today(),
                To__c  = Date.today().addDays(5)
            ));
        }
        insert rsList;
    }
}