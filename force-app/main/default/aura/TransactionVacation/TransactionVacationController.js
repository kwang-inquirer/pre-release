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
		if(thisTL.isBigObject === false){
			var currentDate = new Date();
			var FirstDate = new Date(thisTL.First_Date);
			var LastDate = new Date(thisTL.Last_Date);
			if(FirstDate.getTime() >= currentDate.getTime()){
				component.set("v.CanCancel","True");
				component.set("v.CanEditFirst","True");
			} 
			if(LastDate.getTime() >= currentDate.getTime()){
				component.set("v.CanEditLast","True");
			} 
		}
		var TopHR = component.find("TopHR");
		var BottomHR = component.find("BottomHR");
		$A.util.addClass(TopHR, useCSS);
		$A.util.addClass(BottomHR, useCSS);
  	},
    CancelVacation: function (component, event, helper) {
        var a = component.get("c.CancelTransaction");
		var thisTL = component.get('v.transactionLogToUse');
        a.setParams({ strTransactionId: thisTL.Id });
        a.setCallback(this, function (action) {
            if (action.getState() === "SUCCESS") {
				if(action.getReturnValue() === "success"){
					var compEvent = component.getEvent("TransactionLogEvent");
					compEvent.setParam({"MessageFromDetail":"Refresh"});
					compEvent.fire();
					helper.showToastMessage("Success!","This vacation request has been cancelled successfully.","success");
				}else{
					helper.showToastMessage("Error",action.getReturnValue(),"error");
				}
			} else {
				console.log(action.getError());
				helper.showToastMessage("Error!",action.getError()[0].message,"error");
			}
        });
        // Add the Apex action to the queue
        $A.enqueueAction(a);
    },
    UpdateVacation: function (component, event, helper) {
		var thisTL = component.get('v.transactionLogToUse');	
		if(thisTL.First_Date > thisTL.Last_Date){
			helper.showToastMessage("Error","Start date cannot happen after Restart Date.","error");			
		}else{
			var a = component.get("c.UpdateVacationTransaction");
			a.setParams({ strTransactionId: thisTL.Id, FirstDate: thisTL.First_Date, LastDate: thisTL.Last_Date });
			a.setCallback(this, function (action) {
				if (action.getState() === "SUCCESS") {
					if(action.getReturnValue() === "success"){
						var compEvent = component.getEvent("TransactionLogEvent");
						compEvent.setParam({"MessageFromDetail":"Refresh"});
						compEvent.fire();
						helper.showToastMessage("Success!","Updated successfully.","success");
					}else{
						helper.showToastMessage("Error",action.getReturnValue(),"error");
					}
				} else {
					console.log(action.getError());
					helper.showToastMessage("Error!",action.getError()[0].message,"error");
				}
			});
			// Add the Apex action to the queue
			$A.enqueueAction(a);
		}
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