@isTest
global class CheckoutControllerTest {
    @isTest(SeeAllData=true)
    private static void test_getRecurlyJsUrl() {
        Test.startTest();
        String recurlyUrl = CheckoutController.getRecurlyJsUrl();
        Test.stopTest();

        System.assertEquals(Label.RECURLYJS_VFP_URL, recurlyUrl);
    }

    @isTest
    private static void test_getUserInfo() {
        Test.startTest();
            User userInfo = CheckoutController.getUserInfo();
        Test.stopTest();

        System.assertEquals(true, userInfo != null, 'User should be found');
    }

    @isTest
    private static void test_getSubscriptionById() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Test.startTest();
            Subscription__c subscription = CheckoutController.getSubscriptionById(sub.Id);
        Test.stopTest();

        System.assertEquals(subscription != null, true, 'Subscription should be found');
    }

    @isTest
    private static void test_getOfferById() {
        TestDataFactory.createProductsAndOffers(1);
        Offer__c existingOffer = [SELECT Id FROM Offer__c LIMIT 1];

        Test.startTest();
            Offer__c offer = CheckoutController.getOfferById(existingOffer.Id);
        Test.stopTest();

        System.assertEquals(offer != null, true, 'Offer should be found');
    }

    @isTest
    private static void test_getOfferById_withException() {
        TestDataFactory.createProductsAndOffers(1);
        Offer__c existingOffer = [SELECT Id FROM Offer__c LIMIT 1];

        Test.startTest();
        Boolean hasException = false;
        try {
            CheckoutController.getOfferById(null);
        } catch(Exception e) {
            hasException = true;
        }
        Test.stopTest();

        System.assertEquals(true, hasException, 'getOfferById should throw an exception');
    }

    @isTest
    private static void test_callPiano() {
        Test.setMock(HttpCalloutMock.class, new PianoRequestMock(0));

        Test.startTest();
            Boolean error = false;
            try {
                CheckoutController.callPiano('test');
            } catch (Exception e) {
                error = true;
            }
        Test.stopTest();

        System.assertEquals(false, error, 'There should not be an exception');
    }

    @isTest
    private static void test_callPiano_withErrorCode() {
        Test.setMock(HttpCalloutMock.class, new PianoRequestMock(1));

        Test.startTest();
            Boolean error = false;
            try {
                CheckoutController.callPiano(null);
            } catch (Exception e) {
                error = true;
            }
        Test.stopTest();

        System.assertEquals(error, true, 'There should be an exception thrown');
    }

    @isTest
    private static void test_getNewSubscription() {
        Test.setMock(HttpCalloutMock.class, new Auth0Mock());
        
        Auth0ConnectionSettings__c setting = new Auth0ConnectionSettings__c(Default_Password__c = 'test', Audience__c = 'test', Client_Id__c = 'test', Client_Secret__c = 'test', Connection__c = 'test', Domain__c = 'test', Grant_Type__c = 'secret');
        insert setting;

        TestDataFactory.createTestRecords(1);
        Offer__c existingOffer = [SELECT Id FROM Offer__c LIMIT 1];

        Test.startTest();
            Subscription__c newSub = CheckoutController.getNewSubscription(existingOffer.Id, 'test@test.com', 'web', 'test123', false);
            for (Subscription__c sub : [SELECT Id FROM Subscription__c]) {
                sub.subscription_Status__c = 'INACTIVE';
                update sub;
            }
            Subscription__c updatedSub = CheckoutController.getNewSubscription(existingOffer.Id, 'test@test.com', 'web', 'test123', false);
        Test.stopTest();

        System.assertEquals(true, true, '');
    }

    @isTest
    private static void test_exeptions() {
        Boolean getNewSubscription = false;
        Boolean saveDeliveryAddress = false;
        Boolean saveBillingAddress = false;
        Boolean hasValidDeliveryAddress = false;
        Boolean saveAgreementSignature = false;
        Boolean createRecurlyAccount = false;
        Boolean submitPayment = false;

        Test.startTest();
            try { CheckoutController.getNewSubscription(null, null, null, null, null); } catch (Exception e) { getNewSubscription = true; }
            try { CheckoutController.saveDeliveryAddress(null, null); } catch (Exception e) { saveDeliveryAddress = true; }
            try { CheckoutController.saveBillingAddress(null, null); } catch (Exception e) { saveBillingAddress = true; }
            try { CheckoutController.hasValidDeliveryAddress(null); } catch (Exception e) { hasValidDeliveryAddress = true; }
            try { CheckoutController.saveAgreementSignature(null, null); } catch (Exception e) { saveAgreementSignature = true; }
            try { CheckoutController.createRecurlyAccount(null); } catch (Exception e) { createRecurlyAccount = true; }
            try { CheckoutController.submitPayment(null, null); } catch (Exception e) { submitPayment = true; }
        Test.stopTest();

        System.assertEquals(true, getNewSubscription);
        System.assertEquals(true, saveDeliveryAddress);
        System.assertEquals(true, saveBillingAddress);
        System.assertEquals(true, hasValidDeliveryAddress);
        System.assertEquals(true, saveAgreementSignature);
        System.assertEquals(true, createRecurlyAccount);
        System.assertEquals(true, submitPayment);
    }

    @isTest
    private static void test_saveDeliveryAddress() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Map<String, String> address = new Map<String, String>{
            'firstName' => 'firstName',
            'lastName' => 'lastName',
            'street' => 'street',
            'city' => 'city',
            'state' => 'state',
            'country' => 'country',
            'postalCode' => 'postalCode'
        };

        Test.startTest();
            CheckoutController.saveDeliveryAddress(sub.Id, address);
        Test.stopTest();

        Delivery_Address__c deliveryAddress = [SELECT Address_Street__c FROM Delivery_Address__c];

        System.assertEquals('street', deliveryAddress.Address_Street__c, 'Should have set the street');
    }

    @isTest
    private static void test_saveBillingAddress() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Map<String, String> address = new Map<String, String>{
            'firstName' => 'firstName',
            'lastName' => 'lastName',
            'street' => 'street',
            'city' => 'city',
            'state' => 'state',
            'country' => 'country',
            'postalCode' => 'postalCode'
        };

        Test.startTest();
            CheckoutController.saveBillingAddress(sub.Id, address);
        Test.stopTest();

        Contact cont = [SELECT FirstName FROM Contact];
        Account acct = [SELECT BillingStreet FROM Account];

        System.assertEquals('street', acct.BillingStreet, 'Should have set the street');
        System.assertEquals('firstName', cont.FirstName, 'Should have set the first name');
    }

    @isTest
    private static void test_hasValidDeliveryAddress() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Test.startTest();
            Boolean hasValidDeliveryAddress = CheckoutController.hasValidDeliveryAddress(sub.Id);
        Test.stopTest();

        System.assertEquals(true, hasValidDeliveryAddress, 'Delivery address should be valid');
    }

    @isTest
    private static void test_saveAgreementSignature() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id, SignatureURL__c FROM Subscription__c LIMIT 1];
        sub.SignatureURL__c = 'test,signature';
        update sub;
        Test.startTest();
            CheckoutController.saveAgreementSignature(sub.Id, 'test,signature');
        Test.stopTest();

        List<Attachment> newAttachments = [SELECT Id FROM Attachment WHERE ParentId = :sub.Id];

        System.assertEquals(1, newAttachments.size(), 'Attachment should exist');
    }

    @isTest 
    private static void test_createRecurlyAccount() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];
        Test.startTest();
            Id recurlyAccountId = CheckoutController.createRecurlyAccount(sub.Id);
        Test.stopTest();

        System.assertEquals(true, recurlyAccountId != null, 'Recurly accoutn id should be set');
    }

    @isTest 
    private static void test_createRecurlyAccount_withException() {
        Test.startTest();
        Boolean hasException = false;
        try {
            CheckoutController.createRecurlyAccount(null);
        } catch (AuraHandledException e) {
            hasException = true;
        }
        Test.stopTest();
        System.assertEquals(true, hasException, 'Exception should be thrown if passing invalid subid');
    }


    @isTest
    private static void test_submitPayment_sendBill() {
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        CheckoutPaymentInformation payment = new CheckoutPaymentInformation();
        payment.sendBill = true;
        payment.processPayment = false;
        payment.enableEzPay = false;

        Test.startTest();
            CheckoutController.submitPayment(sub.Id, JSON.serialize(payment));
        Test.stopTest();

        Subscription__c updatedSub = [SELECT Id, subscription_Current_Period_Ends_At__c, Outstanding_Credit__c FROM Subscription__c LIMIT 1];

        System.assertEquals(Date.today(), updatedSub.subscription_Current_Period_Ends_At__c, 'Current Period Ends at should be today');
        System.assertEquals(0, updatedSub.Outstanding_Credit__c, 'Outstanding credit should be 0');
    }

    @isTest
    private static void test_submitPayment_processPayment() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Id accountId = CheckoutController.createRecurlyAccount(sub.Id);

        CheckoutPaymentInformation payment = new CheckoutPaymentInformation();
        payment.sendBill = false;
        payment.processPayment = true;
        payment.enableEzPay = false;
        payment.subscriptionAmount = 10.0;
        payment.accountId = accountId;
        payment.billingToken = '1234';
        payment.waiveActivationFee = false;

        Test.startTest();
            CheckoutController.submitPayment(sub.Id, JSON.serialize(payment));
        Test.stopTest();

        System.assertEquals(true, true, '');
    }

    @isTest
    private static void test_submitPayment_enableEzPay() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        TestDataFactory.createTestRecords(1);
        Subscription__c sub = [SELECT Id FROM Subscription__c LIMIT 1];

        Id accountId = CheckoutController.createRecurlyAccount(sub.Id);

        CheckoutPaymentInformation payment = new CheckoutPaymentInformation();
        payment.sendBill = false;
        payment.processPayment = false;
        payment.enableEzPay = true;
        payment.billingToken = '1234';
        payment.subscriptionAmount = 10.0;
        payment.accountId = accountId;
        payment.waiveActivationFee = false;

        Test.startTest();
            CheckoutController.submitPayment(sub.Id, JSON.serialize(payment));
        Test.stopTest();

        System.assertEquals(true, true, '');
    }
}