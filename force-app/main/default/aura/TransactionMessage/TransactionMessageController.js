({
	doInit: function(component, event, helper) {    
		var useCSS = '';
		var thisTL = component.get('v.transactionLogToUse');
		var settings = component.get('v.TypeSettings');

		var i;
		for (i = 0; i < settings.length; i++) {

			if(thisTL.Category==settings[i].Label){
				useCSS = settings[i].Color_Value__c;
				break;
			}
		}

		console.log('setting the hr class: ' + useCSS);
		var TopHR = component.find("TopHR");
		var BottomHR = component.find("BottomHR");
		$A.util.addClass(TopHR, useCSS);
		$A.util.addClass(BottomHR, useCSS);
  	},


	openTabWithSubtab : function(component, event, helper) {
		var workspaceAPI = component.find("workspace");
		workspaceAPI.openTab({
			url: '/lightning/r/Account/001xx000003DI05AAG/view',
			focus: true
		}).then(function(response) {
			workspaceAPI.openSubtab({
				parentTabId: response,
				url: '/lightning/r/Contact/003xx000004Ts30AAC/view',
				focus: true
			});
		})
			.catch(function(error) {
				console.log(error);
			});

	},
	redirectToTransLog : function(component, event, helper) {
		var urlEvent = $A.get("e.force:navigateToURL");

		urlEvent.setParams({
			"url": '/'+component.get('v.transactionLogToUse').Id,
			"target": "_top"

		});

		urlEvent.fire();

	}

})