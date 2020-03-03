({
    doInit: function (component, event, helper) {
        var today = new Date();
        today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");

        component.set('v.startDate', today);
        component.set('v.endDate', today);
        component.set('v.paymentTypeOptions', [{label: 'Credit', value: 'Credit'}, {label: 'Debit', value: 'Debit'}]);

        helper.getSubscription(component)
            .then(subscription => {
                component.set('v.existingCreditAmount', subscription.Outstanding_Credit__c);
            });

        helper.getOfferProducts(component)
            .then(offerProducts => {
                helper.setOfferProductOptions(component, offerProducts);
            });
    },

    onCalculate: function (component, event, helper) {
        helper.calculate(component)
            .then(result => {
                component.set("v.creditAmount", result);
            });
    },


    onSubmit: function (component, event, helper) {
        component.set('v.successMessage', null);
        component.set('v.errorMessage', null);

        var type = component.get("v.paymentType");
        var params = {
            subscriptionId: component.get("v.recordId"), 
            transactionType: component.get("v.transactionTypeId"),
            amount: component.get("v.creditAmount"),
            paymentType: component.get("v.paymentType"),
            message: component.get("v.message"), 
            startDate: component.get("v.startDate"), 
            endDate: component.get("v.endDate"), 
            offerProductIds: component.get('v.selectedOfferProducts')
        }
        var action = component.get("c.submit");
        action.setParams(params);
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set('v.creditAmount', null);
                component.set('v.message', null);
                component.set('v.successMessage', 'Successfully submitted the amount');
                component.set("v.dayAfterSubExpDate", response.getReturnValue());
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                component.set('v.errorMessage', 'Problem applying the amount, response state : ' + state);
            }
        });
        $A.enqueueAction(action);
    },

    clearCreditAmount : function(component, event, helper) {
        component.set('v.creditAmount', null);
    }
})