public with sharing class RecurlyInvoiceRefund {
    private recurly_v2__Recurly_Invoice__c invoice;
    private RecurlyApi recurlyApi;

    public static final String REFUND_ERROR = 'Failed to refund the invoice';
    public static final String REFUND_ERROR_LINE_ITEMS = 'Invalid invoice line items';
    public static final String REFUND_ERROR_AMOUNT = 'Invalid refund amount';

    public RecurlyInvoiceRefund(Id invoiceId) {
        recurlyApi = new RecurlyApi();
        invoice = RecurlyInvoiceDataAccessor.getInvoiceById(invoiceId);
    }

    public void refundByAmount(Decimal amount) {
        validateByAmount(amount);

        recurlyApi.refundInvoice(invoice.Name, new RecurlyApiObjects.Refund(amount));
        invoice.Refund_Type__c = 'Amount';
        update invoice;
    }

    public void refundByLineItems(List<Id> lineItems) {
        validateByLineItems(lineItems);System.debug(1);
        
        List<RecurlyApiObjects.RefundLineItem> refundLineItems = new List<RecurlyApiObjects.RefundLineItem>();
        for (recurly_v2__Recurly_Line_Item__c lineItem : invoice.recurly_v2__Recurly_Line_Items__r) {
            for (Id lineItemId : lineItems) {
                if (lineItem.Id == lineItemId) {
                    refundLineItems.add(new RecurlyApiObjects.RefundLineItem(lineItem.recurly_v2__LineItemID__c, lineItem.recurly_v2__Quantity__c));
                    lineItem.Refunded__c = true;
                }
            }
        }System.debug(2);

        if (refundLineItems.isEmpty()) {
            throw new GenericException(REFUND_ERROR_LINE_ITEMS);
        }
        System.debug(3);
        recurlyApi.refundInvoice(invoice.Name, new RecurlyApiObjects.Refund(refundLineItems));
        System.debug(4);
        invoice.Refund_Type__c = 'Line Items';
        update invoice;System.debug(5);
        update invoice.recurly_v2__Recurly_Line_Items__r;System.debug(6);
    }

    private void validateByAmount(Decimal amount) {
        if (amount == null || amount < 0 || amount > invoice.recurly_v2__Total__c) {
            throw new GenericException(REFUND_ERROR_AMOUNT);
        }
    }

    private void validateByLineItems(List<Id> lineItems) {
        if (lineItems == null || lineItems.isEmpty()) {
            throw new GenericException(REFUND_ERROR_LINE_ITEMS);
        }
    }
}