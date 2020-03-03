({
	doInit: function(component, event, helper) {
		console.log("Loading journal entries");
        // load filter list
        helper.getJournalEntryList(component);        
    }
})