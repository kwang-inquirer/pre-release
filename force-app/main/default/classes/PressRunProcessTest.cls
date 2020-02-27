@isTest
private class PressRunProcessTest {
    @testSetup 
    static void setup() {

         Account account = new Account(
            Name = 'RelationEdge');
        insert account;
        Subscription__c subscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdge',
            Delivery_Instructions__c = 'Leave at front door',
            Outstanding_Credit__c = 20.25,
            subscription_Status__c = 'Active'
        );
        insert subscription;
        Subscription__c subscriptionOptOut = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdgeOptOut',
            Delivery_Instructions__c = 'Leave at front door',
            Outstanding_Credit__c = 40.25,
            subscription_Status__c = 'Active',
            Premium_Opt_Out__c = true
        );
        insert subscriptionOptOut;
        

        Product2 product = new Product2(Name = '175');
        insert product;
        Offer__c offer = new Offer__c(Name = 'Offer1');
        insert offer;

        Product2 digitalProduct = new Product2(Name = '160', IsDigital__c = true);
        insert digitalProduct;
        Offer__c digitalOffer = new Offer__c(Name = 'Offer1');
        insert digitalOffer;

        
        

        Offer_Product__c offerProduct1 = new Offer_Product__c(
            Offer__c = offer.Id,
            Product__c = product.Id,
            Per_Copy__c = 1.25,
            Per_Copy_Sunday__c = 2.5
        );
        insert offerProduct1;

        Offer_Product__c offerProduct2 = new Offer_Product__c(
            Offer__c = offer.Id,
            Product__c = product.Id,
            Per_Copy__c = 2.0,
            Per_Copy_Sunday__c = 4.0
        );
        insert offerProduct2;

        Offer_Product__c digitalOfferProduct = new Offer_Product__c(
            Offer__c = digitalOffer.Id,
            Product__c = digitalProduct.Id,
            Per_Copy__c = 3.0,
            Per_Copy_Sunday__c = 5.0
        );
        insert digitalOfferProduct;

        Subscription__c digitalSubscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'Digital RelationEdge',
            Delivery_Instructions__c = 'N/A',
            Outstanding_Credit__c = 10.55,
            subscription_Status__c = 'Active',
            subscription_Offer__c = digitalOffer.Id
        );
        insert digitalSubscription;

        Delivery_Address__c deliveryAddress = new Delivery_Address__c();
        deliveryAddress.Address_Street__c = '1265 Lombardi Ave';
        deliveryAddress.Address_City__c = 'Green Bay';
        deliveryAddress.Address_State__c = 'WI';
        insert deliveryAddress;

        Delivery_Schedule__c deliveryScheduleNoDays = new Delivery_Schedule__c();
        deliveryScheduleNoDays.subscription_Subscription__c = subscription.Id;
        deliveryScheduleNoDays.Delivery_Address__c = deliveryAddress.Id;
        deliveryScheduleNoDays.Day_Monday__c = false;
        deliveryScheduleNoDays.Day_Tuesday__c = false;
        deliveryScheduleNoDays.Day_Wednesday__c = false;
        deliveryScheduleNoDays.Day_Thursday__c = false;
        deliveryScheduleNoDays.Day_Friday__c = false;
        deliveryScheduleNoDays.Day_Saturday__c = false;
        deliveryScheduleNoDays.Day_Sunday__c = false;
        deliveryScheduleNoDays.Start_Date__c = Date.today();
        deliveryScheduleNoDays.End_Date__c = Date.today()+7;
        deliveryScheduleNoDays.Offer_Product__c = offerProduct1.Id;

        Delivery_Schedule__c deliveryScheduleAllDays = new Delivery_Schedule__c();
        deliveryScheduleAllDays.subscription_Subscription__c = subscription.Id;
        deliveryScheduleAllDays.Delivery_Address__c = deliveryAddress.Id;
        deliveryScheduleAllDays.Day_Monday__c = true;
        deliveryScheduleAllDays.Day_Tuesday__c = true;
        deliveryScheduleAllDays.Day_Wednesday__c = true;
        deliveryScheduleAllDays.Day_Thursday__c = true;
        deliveryScheduleAllDays.Day_Friday__c = true;
        deliveryScheduleAllDays.Day_Saturday__c = true;
        deliveryScheduleAllDays.Day_Sunday__c = true;
        deliveryScheduleAllDays.Start_Date__c = Date.today();
        deliveryScheduleAllDays.End_Date__c = Date.today()+7;
        deliveryScheduleAllDays.Offer_Product__c = offerProduct1.Id;

        Delivery_Schedule__c deliveryScheduleAllDaysOptOut = new Delivery_Schedule__c();
        deliveryScheduleAllDaysOptOut.subscription_Subscription__c = subscriptionOptOut.Id;
        deliveryScheduleAllDaysOptOut.Delivery_Address__c = deliveryAddress.Id;
        deliveryScheduleAllDaysOptOut.Day_Monday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Tuesday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Wednesday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Thursday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Friday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Saturday__c = true;
        deliveryScheduleAllDaysOptOut.Day_Sunday__c = true;
        deliveryScheduleAllDaysOptOut.Start_Date__c = Date.today();
        deliveryScheduleAllDaysOptOut.End_Date__c = Date.today()+7;
        deliveryScheduleAllDaysOptOut.Offer_Product__c = offerProduct2.Id;

        Delivery_Schedule__c deliveryScheduleNoDaysOptOut = new Delivery_Schedule__c();
        deliveryScheduleNoDaysOptOut.subscription_Subscription__c = subscriptionOptOut.Id;
        deliveryScheduleNoDaysOptOut.Delivery_Address__c = deliveryAddress.Id;
        deliveryScheduleNoDaysOptOut.Day_Monday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Tuesday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Wednesday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Thursday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Friday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Saturday__c = false;
        deliveryScheduleNoDaysOptOut.Day_Sunday__c = false;
        deliveryScheduleNoDaysOptOut.Start_Date__c = Date.today();
        deliveryScheduleNoDaysOptOut.End_Date__c = Date.today()+7;
        deliveryScheduleNoDaysOptOut.Offer_Product__c = offerProduct2.Id;


        
        insert deliveryScheduleNoDays;
        insert deliveryScheduleAllDays;
        insert deliveryScheduleAllDaysOptOut;
        insert deliveryScheduleNoDaysOptOut;
        
    }
    static testmethod void shouldBatchInactivePressDay() {        
        Test.startTest();
        PressRunProcess prp = new PressRunProcess();
        prp.activePremium = false;
        prp.dayOfWeek = 'Monday';
        Id batchId = Database.executeBatch(prp);
		Test.stopTest();
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        system.assert(journalEntries.size() > 0);

        
    }
    static testmethod void shouldBatchInactivePressDaySunday() {        
        Test.startTest();
        PressRunProcess prp = new PressRunProcess();
        prp.activePremium = false;
        prp.dayOfWeek = 'Sunday';
        Id batchId = Database.executeBatch(prp);
        Test.stopTest();
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        system.assert(journalEntries.size() > 0);
        
    }

    static testmethod void shouldBatchActivePressDay() {        
        Test.startTest();
        PressRunProcess prp = new PressRunProcess();
        prp.activePremium = true;
        prp.dayOfWeek = 'Monday';
        Id batchId = Database.executeBatch(prp);
        Test.stopTest();
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        system.assert(journalEntries.size() > 0);
        
    }

    static testmethod void shouldBatchActivePressDaySunday() {        
        Test.startTest();
        PressRunProcess prp = new PressRunProcess();
        prp.activePremium = true;
        prp.dayOfWeek = 'Sunday';
        Id batchId = Database.executeBatch(prp);
        Test.stopTest();
        List<Journal__c> journalEntries = [SELECT Id FROM Journal__c];
        system.assert(journalEntries.size() > 0);
        
    }
    
    static testmethod void shouldScheduleBatchJob(){
        
        String CRON_EXP = '0 0 0 15 3 ? *';
        Test.startTest();
            String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new PressRunScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(CRON_EXP, ct.CronExpression);
            System.assertEquals(0, ct.TimesTriggered);

        Test.stopTest();
    }

    static testmethod void shouldCallAllJobs(){
        
        Test.startTest();
            PressRunSync prp = new PressRunSync();
            Id batchId = Database.executeBatch(prp);
        Test.stopTest();
    }
    
}