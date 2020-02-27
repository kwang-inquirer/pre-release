({
	doInit: function(component, event, helper) {
		console.log("loading JE");
	},
	handleRefundClicked : function(component, event, helper) {
		var transactionLogToUse = component.get('v.transactionLogToUse');
		if (transactionLogToUse.InvoiceId) {
			var recurlyInvoiceRefundEvent = $A.get("e.c:RecurlyInvoiceRefundEvent");
			recurlyInvoiceRefundEvent.setParams({ "invoiceId" : transactionLogToUse.InvoiceId });
			recurlyInvoiceRefundEvent.fire();
		}
	}
})