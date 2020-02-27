({
    handleSuccess: function(component) {
        var subscription = component.get('v.subscription');
        var subscriptionId = component.get('v.subscriptionId');
        var tipAmount = component.get('v.tipAmount');
        subscription.Id = subscriptionId;
        subscription.Auto_Renew_Tip__c = parseFloat(tipAmount);
        subscription.subscription_Auto_Renew__c = true;
        this.updateSubscription(subscription, component, function() {
            var navigate = component.get("v.navigateFlow");
            navigate("FINISH");
        });
    },
    updateSubscription: function(subscription, component, callback) {
        var action = component.get("c.updateSubscription");
        action.setParams({ subscription : subscription });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback();
            }
        });
        $A.enqueueAction(action);
    }
})