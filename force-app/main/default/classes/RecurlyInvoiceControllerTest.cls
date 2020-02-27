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

        Boolean invalidLineItemsException = false;
        Boolean invalidInvoiceNumberException = false;
        Test.startTest();
            RecurlyInvoiceController.refundByLineItems(invoice.Id, new List<String>{'123'});
            try {
                RecurlyInvoiceController.refundByLineItems(invoice.Id, null);
            } catch (Exception e) {
                invalidLineItemsException = true;
            }
            try {
                RecurlyInvoiceController.refundByLineItems(null, new List<String>{'123'});
            } catch (Exception e) {
                invalidInvoiceNumberException = true;
            }
        Test.stopTest();

        System.assert(invalidLineItemsException); 
        System.assert(invalidInvoiceNumberException); 
    }
}