public with sharing class RecurlyInvoiceController {
    @AuraEnabled
    public static RecurlyApiObjects.Invoice getInvoice(String invoiceId) {
        recurly_v2__Recurly_Invoice__c invoice = getInvoiceById(invoiceId);
        RecurlyApiObjects.Invoice apiInvoice = new RecurlyApi().getInvoice(invoice.Name);
        System.debug(apiInvoice);
        return apiInvoice;
    }

    @AuraEnabled
    public static void refundByAmount(String invoiceNumber, Decimal amount) {
        try {
            if (invoiceNumber == null) {
                throw new GenericException('Invalid invoice number');
            }
            if (amount == null || amount < 0) {
                throw new GenericException('Invalid amount');
            }
            RecurlyApi recurlyApi = new RecurlyApi();
            RecurlyApi.InvoiceRefund refund = new RecurlyApi.InvoiceRefund(invoiceNumber, amount * 100);
            recurlyApi.refundInvoice(refund);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create the refund');
        }
    }

    @AuraEnabled
    public static void refundByLineItems(String invoiceNumber, List<String> lineItemIds) {
        try {
            if (invoiceNumber == null) {
                throw new GenericException('Invalid invoice');
            }
            if (lineItemIds == null || lineItemIds.isEmpty()) {
                throw new GenericException('Invalid line items');
            }
            RecurlyApi recurlyApi = new RecurlyApi();
            List<RecurlyApiObjects.AdjustmentDetails> adjustments = new List<RecurlyApiObjects.AdjustmentDetails>();
            for (String id : lineItemIds) {
                adjustments.add(new RecurlyApiObjects.AdjustmentDetails(id, 1));
            }
            RecurlyApi.InvoiceRefund refund = new RecurlyApi.InvoiceRefund(invoiceNumber, adjustments);
            recurlyApi.refundInvoice(refund);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to create the refund');
        }

    }

    private static recurly_v2__Recurly_Invoice__c getInvoiceById(String invoiceId) {
        return [
            SELECT Id, Name, recurly_v2__Total__c, (SELECT Id, recurly_v2__LineItemID__c, recurly_v2__Amount__c FROM recurly_v2__Recurly_Line_Items__r)
            FROM recurly_v2__Recurly_Invoice__c
            WHERE Id = :invoiceId
        ];
    }
}