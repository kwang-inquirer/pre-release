public with sharing class RecurlyInvoiceController {
    @AuraEnabled
    public static recurly_v2__Recurly_Invoice__c getInvoice(String invoiceId) {
        try {
            return RecurlyInvoiceDataAccessor.getInvoiceById(invoiceId);
        } 
        catch (Exception e) {
            throw new AuraHandledException('Failed to retrieve the invoice');
        }
    }

    @AuraEnabled
    public static void refundByAmount(String invoiceId, Decimal amount) {
        try {
            RecurlyInvoiceRefund invoiceRefund = new RecurlyInvoiceRefund(invoiceId);
            invoiceRefund.refundByAmount(amount);
        } catch (GenericException e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(RecurlyInvoiceRefund.REFUND_ERROR);
        }
    }

    @AuraEnabled
    public static void refundByLineItems(Id invoiceId, List<Id> lineItems) {
        try {
            RecurlyInvoiceRefund invoiceRefund = new RecurlyInvoiceRefund(invoiceId);
            invoiceRefund.refundByLineItems(lineItems);
        } catch (GenericException e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
            throw new AuraHandledException(RecurlyInvoiceRefund.REFUND_ERROR);
        }

    }
}