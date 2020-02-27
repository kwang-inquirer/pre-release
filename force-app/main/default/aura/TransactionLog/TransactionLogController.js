({
    doInit: function(component, event, helper) {     
        // load filter list
        helper.getTransactionTypeList(component);
        helper.checkAllOptions(component,event,helper);
        
    },
    openRecuryInvoiceRefundModal : function(component, event, helper) {
        console.log('openRecuryInvoiceRefundModal ' + event.getParam("invoiceId"));
        component.find('recurlyInvoiceRefundModal').open(event.getParam("invoiceId"));
    },
    //for printing purposes
    /*openWorkLogPDF: function(component, event, helper) {
		var accountId = component.get("v.recordId");
		window.open('/WorkLogCasePDF?Id=' + accountId, '_blank', false);
	},*/
    
    reloadPage: function(component, event, helper) {
        var selectedTLs = event.getParam("value");
        console.log(selectedTLs);
        
        helper.getTransactionLogList(component);
        console.log('Rendering page');
    },
    checkAllOptions: function(component, event, helper){
        helper.checkAllOptions(component,event,helper);
    },
    checkAll: function(component, event){
        var newList = [];
        var optList = component.get("v.tlTypes");
        for (var i = 0; i < optList.length; i++){
            var newValue = "";
            newValue += " " + optList[i].value;
            if(i<optList.length-1){
                newValue += ",";
            }
            newList.push(newValue);
            
        }
        component.set("v.tlSelectedTypes", newValue);
    },
    
    
    uncheckAll:function(component, event, helper) {
        var newValue = "";
        component.set("v.tlSelectedTypes", newValue);
        helper.getTransactionLogList(component);
    },
    
    collapseOptions: function(component, event){
		component.set("v.showOptions", false);
    },
    expandOptions: function(component, event){
        component.set("v.showOptions", true);
    },
    refresh: function(component, event, helper){
	helper.getTransactionLogList(component);
	}
})