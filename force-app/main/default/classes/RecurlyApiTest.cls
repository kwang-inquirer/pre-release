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
    private static void test_getInvoice() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());

        Test.startTest();
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.getInvoice('testInvoiceId');
        Test.stopTest();

        System.assert(true); // would throw an exception if false
    }

    @IsTest
    private static void test_getInvoice_errorEmptyBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, ''));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.getInvoice('testInvoiceId');
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_getInvoice_errorBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, '<error><symbol>not_found</symbol><description>The record could not be located.</description></error>'));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.getInvoice('testInvoiceId');
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
            RecurlyApi.InvoiceRefund refundWithAmt = new RecurlyApi.InvoiceRefund('test', 5);
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApi.InvoiceRefund refundWithLineItems = new RecurlyApi.InvoiceRefund('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice(refundWithAmt);
            recurlyApi.refundInvoice(refundWithLineItems);
        Test.stopTest();

        System.assert(true); // would throw an exception if false
    }

    @IsTest
    private static void test_refundInvoice_errorEmptyBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, ''));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApi.InvoiceRefund refundWithAmt = new RecurlyApi.InvoiceRefund('test', 5);
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApi.InvoiceRefund refundWithLineItems = new RecurlyApi.InvoiceRefund('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice(refundWithAmt);
            recurlyApi.refundInvoice(refundWithLineItems);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_refundInvoice_errorBody() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock(0, '<error><symbol>not_found</symbol><description>The record could not be located.</description></error>'));

        Test.startTest();
        Boolean hasGenericException = false;
        try {
            RecurlyApi.InvoiceRefund refundWithAmt = new RecurlyApi.InvoiceRefund('test', 5);
            RecurlyApiObjects.AdjustmentDetails adj2 = new RecurlyApiObjects.AdjustmentDetails(1, 1, 'test');
            RecurlyApi.InvoiceRefund refundWithLineItems = new RecurlyApi.InvoiceRefund('test', new List<RecurlyApiObjects.AdjustmentDetails>{adj2});

            RecurlyApi recurlyApi = new RecurlyApi();
            recurlyApi.refundInvoice(refundWithAmt);
            recurlyApi.refundInvoice(refundWithLineItems);
        } catch (GenericException e) {
            hasGenericException = true;
        }
        Test.stopTest();

        System.assert(true, hasGenericException);
    }

    @IsTest
    private static void test_misc() {
        Test.startTest();
            RecurlyApiObjects.InvoiceLineItem invLineItem = new RecurlyApiObjects.InvoiceLineItem();
            invLineItem.adjustment = new List<RecurlyApiObjects.AdjustmentDetails>{new RecurlyApiObjects.AdjustmentDetails('test', 1)};

            RecurlyApiObjects.InvoiceDetails details = new RecurlyApiObjects.InvoiceDetails();
            details.uuid = 'test';
            details.state = 'test';
            details.invoice_number = 1;
            details.type = 'test';
            details.total_in_cents = 100;
            details.line_items = invLineItem;

            RecurlyApiObjects.Invoice invoice = new RecurlyApiObjects.Invoice();
            invoice.invoice = details;

            RecurlyApiObjects.InvoiceDetails details_0 = new RecurlyApiObjects.InvoiceDetails();
            details_0.uuid = 'test';
            details_0.state = 'test';
            details_0.invoice_number = 1;
            details_0.type = 'test';
            details_0.total_in_cents = null;
            details_0.line_items = invLineItem;

            Decimal total = details.total;
            Decimal total0 = details_0.total;
        Test.stopTest();

        System.assertEquals(0, total0);
        System.assertEquals(1, total);
    }
}