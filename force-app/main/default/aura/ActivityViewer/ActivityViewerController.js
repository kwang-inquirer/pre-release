({
	doInit: function (component, event, helper) {

	},

	displayTransactions:function(component, event){
		component.set("v.showTransactions", true);
		component.set("v.showJournals", false);
		console.log("Show transactions: " + component.get("v.showTransactions"));
    },

	displayJournals:function(component, event){
		component.set("v.showTransactions", false);
		component.set("v.showJournals", true);
    }
})