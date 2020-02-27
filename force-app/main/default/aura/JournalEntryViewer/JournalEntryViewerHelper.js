({
    // Fetch the CUSTOMER SALES from the Apex controller
    getJournalEntryList: function(component) {
        var recordId = component.get("v.recordId");
        var filterBy = '';
        var action = component.get("c.PullJournalEntries");
        
        action.setParams({"sobjId" : recordId, "filterType" : filterBy});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state == "SUCCESS") {
                var retVal = actionResult.getReturnValue();
                component.set("v.getJournalEntryList", retVal);
            }else if (state == "ERROR") {
                var errors = actionResult.getError();
                console.log('Error : ' + errors);
            }
        });
        $A.enqueueAction(action);
    }
})