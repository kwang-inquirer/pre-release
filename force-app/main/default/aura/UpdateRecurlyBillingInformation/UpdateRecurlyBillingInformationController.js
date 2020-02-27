({
    handleSubmit : function(component, event, helper){
        var subscriptionData = {};
    	var names = component.get('v.nameOnCard');
    	var firstName = names.split(' ').slice(0, -1).join(' ');
    	var lastName = names.split(' ').slice(-1).join(' ');
        subscriptionData.firstName = firstName;
        subscriptionData.lastName = lastName;
        subscriptionData.cardNumber = component.get('v.cardNumber');
        subscriptionData.ccv = component.get('v.ccv');
        subscriptionData.zip = component.get('v.zip');
        subscriptionData.city = component.get('v.city');
        subscriptionData.state = component.find('stateSelector').get('v.value');
        subscriptionData.accountCode = component.get('v.rcBillingCode');
        subscriptionData.streetAddress = component.get('v.streetAddress');
        subscriptionData.paymentType = component.find("paymentType").get("v.value");
        subscriptionData.cardType = component.find("cardTypeSelector").get("v.value");
        subscriptionData.month = component.find("monthInput").get("v.value");
        subscriptionData.year = component.find("yearInput").get("v.value");
        var a = component.get("c.updatePaymentInformation");
        a.setParams({
            "jsonObject" : JSON.stringify(subscriptionData)
        });
        
        a.setCallback(this, function(action) {
            if (action.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                if(result != null){
                    console.log(a.getReturnValue());
                }
            } else {
                console.log(action.getError());
            }
        });
        $A.enqueueAction(a);
        
    }
})