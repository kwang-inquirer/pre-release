({
    lockTime : function(component){
        var timeZone = new Date().toLocaleString("en-US", {timeZone: "America/New_York"})
        var estTime = new Date(timeZone);
        var lockTime = new Date();
        
        /*Conditionally set the lock time to 6:30 AM on weekends or 8 AM on weekdays.*/
        if(estTime.getDay() === 0 || estTime.getDay() == 6){
            lockTime.setHours(6);
            lockTime.setMinutes(30);
        }
        else{
            lockTime.setHours(6);
            lockTime.setMinutes(30);
        }
        
        if(lockTime > estTime){
            component.set('v.lockTime', true);
        }
        else{
            component.set('v.lockTime', false);
        }
        
        
    },
    populateCredit : function(component, event, helper){
        var list = [];
        list.push({'label': 'Credit', 'value': 'Credit'});
        component.set("v.solutionOptions", list);
        component.set("v.solutionSelected", "Credit");
    },
    populateRedelivery : function(component, event, helper){
        var list2 = [];
        list2.push({'label': 'Redelivery', 'value': 'Redelivery'});
        component.set("v.solutionOptions", list2);
        component.set("v.solutionSelected", "Redelivery");
    },
    populateLockdown : function(component, event, helper){
        var list3 = [];
        component.set("v.solutionOptions", list3);
        component.set("v.solutionSelected", "");
    },
    validateDate : function(component, event, helper){
        let button = component.find('submitButtonId');
        var cutoff = new Date();
        cutoff.setDate(cutoff.getDate() - 11);
        var today = new Date();
        var selectedDate = new Date(component.get("v.dateSelected"));
        if(cutoff > selectedDate || selectedDate > today){
            component.set("v.dateValidationError" , true);
            component.set("v.deliveryValidationError", false);
            component.set("v.submitDisabled", true);
        }
        else{
            component.set("v.dateValidationError" , false);
            var a = component.get("c.validateDeliveryDate");
            a.setParams({ subscriptionId : component.get("v.subscriptionId"), selectedDate : component.get('v.dateSelected')});
            a.setCallback(this, function(action) {
                if (action.getState() === "SUCCESS") {
                    component.set("v.deliveryValidationError", !action.getReturnValue());
                    if(component.get("v.recordCreated") === true || component.get("v.dateValidationError") || component.get("v.deliveryValidationError")){
                        component.set("v.submitDisabled", true);
                    }
                    else{
                        component.set("v.submitDisabled", false);
                    }
                } else {
                    console.log(action.getError());
                }
            });
            // Add the Apex action to the queue
            $A.enqueueAction(a);
        }        
    },
    getOfferProducts : function (component) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.fetchOfferProducts");
            action.setParams({ "subId": component.get("v.subscriptionId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },
    setOfferProductOptions: function (component, offerProducts) {
        var options = [];
        var selectedOptions = [];
        offerProducts.forEach(function (offerProduct) {
            options.push({ label: offerProduct.Name, value: offerProduct.Id });
            selectedOptions.push(offerProduct.Id);
        });
        component.set('v.offerProductOptions', options);
        component.set('v.selectedOfferProducts', selectedOptions);
    },
    getDeliveryIssueList : function (component) {
        return new Promise((resolve, reject) => {
            var action = component.get("c.getDeliveryIssueList");

            action.setParams({ "selectedDate": component.get("v.dateSelected") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },
    setDeliveryIssueOptions: function (component, deliveryIssueList, updateDeliveryIssue) {
        var options = [];
        var selectedValue = [];
        var applyCredit = false;
        var iterator = 0;
        var selectedIssue = component.get('v.deliveryIssueOptionSelected');
        deliveryIssueList.forEach(function (deliveryIssue) {
            options.push({ label: deliveryIssue.Name, value: deliveryIssue.Id });
            if( (iterator==0 && updateDeliveryIssue) || (selectedIssue == deliveryIssue.Id) ){
                selectedValue = deliveryIssue.Id;
                applyCredit = deliveryIssue.Apply_Credit_to_Subscription__c;
                iterator++;
            }
        });

        if (updateDeliveryIssue) {

            component.set('v.deliveryIssueOptions', options);
            // console.log('2was: ' + component.get('v.deliveryIssueOptionSelected'));
            component.set('v.deliveryIssueOptionSelected', selectedValue);
            // console.log(' ... is now: ', component.get('v.deliveryIssueOptionSelected'));
        }
        component.set('v.applyCredit', applyCredit);
    },
    getLatestExpireDate: function (component) {
        var action = component.get("c.getLatestExpireDate");
        action.setParams( { subscriptionId: component.get("v.subscriptionId"), firstDate: component.get('v.dateSelected') });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var retVal = response.getReturnValue();
                component.set('v.expireDate', retVal);

            } else {
                console.log(response.getError());
            }

        });
        // Add the Apex action to the queue
        $A.enqueueAction(action);
    }    

})