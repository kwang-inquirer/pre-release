({
    doInit : function(component, event, helper) {
        if(component.get("v.subscriptionId") != null){
            var a = component.get("c.getSubscriptionDetail");
            a.setParams({subscriptionId : component.get('v.subscriptionId')});
            a.setCallback(this, function(action) {
                if (action.getState() === "SUCCESS") {
                    var result = a.getReturnValue();
                    if(result != null){
                        component.set('v.subscriptionRecord', result);
                    }
                    if(component.get("v.recurlyAccountId") == null){
                        var b = component.get("c.getRecurlyAccount");
                        b.setParams({});
                        b.setCallback(this, function(action) {
                            if (action.getState() === "SUCCESS") {
                                var result = b.getReturnValue();
                                if(result != null){
                                    component.set('v.recurlyAccount', result);
                                    if(component.get('v.recurlyAccount.recurly_v2__Billing_Valid__c') == true){
                                        component.set('v.forceNewPayment', false);
                                    }
                                }
                            } else {
                                console.log(action.getError());
                            }
                        });
                        $A.enqueueAction(b);
                    }
                } else {
                    console.log(action.getError());
                }
            });
            $A.enqueueAction(a);
        }
        
        
    },
    NewVsExistingPaymentChange : function(component, event, helper){
        if(component.get("v.NewOrExisting") == "Update Payment Details"){
            component.set("v.NewPayment", true);
        }
        else{
            component.set("v.NewPayment", false);
        }
    },
    handleSubmitPayment : function(component, event, helper){
        
            var a = component.get("c.updatePaymentInformation");
            a.setParams({
                "accountCode" : component.get('v.recurlyAccount.Id') 
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