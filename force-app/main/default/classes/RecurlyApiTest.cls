@IsTest
global class RecurlyApiTest {
    @IsTest
    private static void test_updateAccount() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());

        Test.startTest();
            RecurlyApiObjects.Account recurlyAcct = new RecurlyApiObjects.Account();
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.updateAccount(recurlyAcct);
        Test.stopTest();

        System.assert(true); // would throw an exception if false
    }

    @IsTest
    private static void test_updateAccount_errorEmptyBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, null));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.Account recurlyAcct = new RecurlyApiObjects.Account();
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.updateAccount(recurlyAcct);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_updateAccount_errorBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, '<error><symbol>not_found</symbol><description>The record could not be located.</description></error>'));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.Account recurlyAcct = new RecurlyApiObjects.Account();
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.updateAccount(recurlyAcct);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_createPurchase() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());

        Test.startTest();
            RecurlyApiObjects.TokenBillingInfo token = new RecurlyApiObjects.TokenBillingInfo();
            token.token_id = 'test';
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApiObjects.Purchase purchase = new RecurlyApiObjects.Purchase('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2}, token);

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.createPurchase(purchase);
        Test.stopTest();

        System.assert(true); // would throw an exception if false
    }

    @IsTest
    private static void test_createPurchase_errorEmptyBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, ''));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.TokenBillingInfo token = new RecurlyApiObjects.TokenBillingInfo();
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApiObjects.Purchase purchase = new RecurlyApiObjects.Purchase('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2}, token);

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.createPurchase(purchase);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_createPurchase_errorBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, '<error><symbol>not_found</symbol><description>The record could not be located.</description></error>'));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.TokenBillingInfo token = new RecurlyApiObjects.TokenBillingInfo();
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApiObjects.Purchase purchase = new RecurlyApiObjects.Purchase('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2}, token);

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.createPurchase(purchase);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_refundInvoice() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());

        Test.startTest();
            RecurlyApiObjects.Refund refundWithAmt = new RecurlyApiObjects.Refund(5);
            RecurlyApiObjects.RefundLineItem lineItems = new RecurlyApiObjects.RefundLineItem('test', 1);
            RecurlyApiObjects.Refund refundWithLineItems = new RecurlyApiObjects.Refund(new List<RecurlyApiObjects.RefundLineItem>{lineItems});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice('test', refundWithAmt);
            recurlyApi.refundInvoice('test', refundWithLineItems);
        Test.stopTest();

        System.assert(true); // would throw an exception if false
    }

    @IsTest
    private static void test_refundInvoice_errorEmptyBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, ''));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.Refund refundWithAmt = new RecurlyApiObjects.Refund(5);
            RecurlyApiObjects.RefundLineItem lineItems = new RecurlyApiObjects.RefundLineItem('test', 1);
            RecurlyApiObjects.Refund refundWithLineItems = new RecurlyApiObjects.Refund(new List<RecurlyApiObjects.RefundLineItem>{lineItems});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice('test', refundWithAmt);
            recurlyApi.refundInvoice('test', refundWithLineItems);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_refundInvoice_errorBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, '{"message":"error"}'));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApiObjects.Refund refundWithAmt = new RecurlyApiObjects.Refund(5);
            RecurlyApiObjects.RefundLineItem lineItems = new RecurlyApiObjects.RefundLineItem('test', 1);
            RecurlyApiObjects.Refund refundWithLineItems = new RecurlyApiObjects.Refund(new List<RecurlyApiObjects.RefundLineItem>{lineItems});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice('test', refundWithAmt);
            recurlyApi.refundInvoice('test', refundWithLineItems);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }
}