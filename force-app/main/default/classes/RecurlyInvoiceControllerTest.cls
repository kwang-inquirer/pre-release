@isTest
global class RecurlyInvoiceControllerTest {
    @isTest
    private static void test_getInvoice() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        recurly_v2__Recurly_Invoice__c invoice = new recurly_v2__Recurly_Invoice__c(recurly_v2__InvoiceID__c = 'test');
        insert invoice;

        Test.startTest();
        recurly_v2__Recurly_Invoice__c invoiceFromRecurly = RecurlyInvoiceController.getInvoice(invoice.Id);
        Test.stopTest();

        System.assertEquals(true, invoiceFromRecurly != null, 'Recurly invoice should be returned');
    }

    @isTest
    private static void test_getInvoice_withError() {
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            RecurlyInvoiceController.getInvoice(null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'An exception should be thrown');
    }
    
    @isTest
    private static void test_refundByAmount() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        recurly_v2__Recurly_Invoice__c invoice = new recurly_v2__Recurly_Invoice__c(recurly_v2__InvoiceID__c = 'test');
        insert invoice;

        Boolean invalidAmountException = false;
        Boolean invalidInvoiceNumberException = false;
        Test.startTest();
            RecurlyInvoiceController.refundByAmount(invoice.Id, 5);
            try {
                RecurlyInvoiceController.refundByAmount(invoice.Id, -50);
            } catch (Exception e) {
                invalidAmountException = true;
            }
            try {
                RecurlyInvoiceController.refundByAmount(null, 5);
            } catch (Exception e) {
                invalidInvoiceNumberException = true;
            }
        Test.stopTest();

        System.assert(invalidAmountException); 
        System.assert(invalidInvoiceNumberException); 
    }

    @isTest
    private static void test_refundByLineItems() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        recurly_v2__Recurly_Invoice__c invoice = new recurly_v2__Recurly_Invoice__c(recurly_v2__InvoiceID__c = 'test');
        insert invoice;

        recurly_v2__Recurly_Line_Item__c lineItem = new recurly_v2__Recurly_Line_Item__c(recurly_v2__Recurly_Invoice__c = invoice.Id);
        insert lineItem;

        Boolean invalidLineItemsException = false;
        Boolean invalidInvoiceNumberException = false;
        Test.startTest();
            RecurlyInvoiceController.refundByLineItems(invoice.Id, new List<String>{lineItem.Id});
            try {
                RecurlyInvoiceController.refundByLineItems(invoice.Id, null);
            } catch (Exception e) {
                invalidLineItemsException = true;
            }
            try {
                RecurlyInvoiceController.refundByLineItems(null, new List<String>{lineItem.Id});
            } catch (Exception e) {
                invalidInvoiceNumberException = true;
            }
        Test.stopTest();

        System.assert(invalidLineItemsException); 
        System.assert(invalidInvoiceNumberException); 
    }
    
    @isTest
    private static void test_refundByLineItems_error_noLineItems() {
        Test.setMock(HttpCalloutMock.class, new RecurlyApiMock());
        recurly_v2__Recurly_Invoice__c invoice = new recurly_v2__Recurly_Invoice__c(recurly_v2__InvoiceID__c = 'test');
        insert invoice;
        
        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            RecurlyInvoiceController.refundByLineItems(invoice.Id, null);
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assert(exceptionThrown); 
    }
}