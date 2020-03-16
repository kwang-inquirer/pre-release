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
            useCSS = 'Orange-hr';
		}
		if (thisTL.isBigObject === false) {
			var currentDate = new Date();
			var todaysDate = new Date(currentDate.getFullYear(), String(currentDate.getMonth() + 1).padStart(2, '0'), String(currentDate.getDate()).padStart(2, '0'));
			var FirstDate = new Date(thisTL.First_Date.split('-')[0], thisTL.First_Date.split('-')[1].padStart(2, '0'), thisTL.First_Date.split('-')[2].padStart(2, '0'));
			if (FirstDate.getTime() > todaysDate.getTime()) {
				component.set("v.CanCancel", "True");
			}
		}

		console.log('setting the hr class: ' + useCSS);
		var TopHR = component.find("TopHR");
		var BottomHR = component.find("BottomHR");
		$A.util.addClass(TopHR, useCSS);
		$A.util.addClass(BottomHR, useCSS);
  	},
	CancelStartStopTransaction: function (component, event, helper) {
		var a = component.get("c.CancelTransaction");
		var thisTL = component.get('v.transactionLogToUse');
		a.setParams({ strTransactionId: thisTL.Id });
		a.setCallback(this, function (action) {
			if (action.getState() === "SUCCESS") {
				if (action.getReturnValue() === "success") {
					$A.get('e.force:refreshView').fire();
					var compEvent = component.getEvent("TransactionLogEvent");
					compEvent.setParam({ "MessageFromDetail": "Refresh" });
					compEvent.fire();
					helper.showToastMessage("Success!", "Updated successfully.", "success");
				} else {
					helper.showToastMessage("Error", action.getReturnValue(), "error");
				}
			} else {
				console.log(action.getError());
				helper.showToastMessage("Error", "Unable to cancel Start Stop." + action.getError()[0].message, "error");
			}
		});
		// Add the Apex action to the queue
		$A.enqueueAction(a);
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