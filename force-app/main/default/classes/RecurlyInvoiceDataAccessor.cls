public with sharing class RecurlyInvoiceDataAccessor {
    public static recurly_v2__Recurly_Invoice__c getInvoiceById(Id invoiceId) {
        return [
            SELECT Id, Name, recurly_v2__Total__c, Refund_Type__c, (SELECT Id, recurly_v2__LineItemID__c, recurly_v2__Amount__c, recurly_v2__Line_Item_Description__c, recurly_v2__Quantity__c, Refunded__c FROM recurly_v2__Recurly_Line_Items__r)
            FROM recurly_v2__Recurly_Invoice__c
            WHERE Id = :invoiceId
        ];
    }
}