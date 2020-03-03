({
    doInit: function (component, event, helper) {
        if (component.get("v.subscriptionId") != null) {
			component.set('v.subscriptionNull', false);
            var today = new Date();
			component.set('v.dateSelected', today.getFullYear() + "-" + (today.getMonth() + 1) + "-" + today.getDate());

			helper.getOfferProducts(component)
				.then(offerProducts => {
					helper.setOfferProductOptions(component, offerProducts);
				});

            helper.getDeliveryIssueList(component) 
                .then( deliveryIssueList => {
                    helper.setDeliveryIssueOptions(component, deliveryIssueList);
            });
        }


    },

    submitIssue: function (component, event, helper) {
        console.log('here: ' + component.get('v.deliveryIssueOptionSelected'));
        var a = component.get("c.InsertTransaction");
        a.setParams({ subscriptionId: component.get("v.subscriptionId"), transactionTypeId: component.get('v.deliveryIssueOptionSelected'), serviceIssue: component.get('v.serviceIssueSelected'), 
                      request: component.get('v.solutionSelected'), selectedDate: component.get('v.dateSelected'), 
                      selectedOfferProducts: component.get('v.selectedOfferProducts'), memo: component.get('v.memo') });
        a.setCallback(this, function (action) {
            if (action.getState() === "SUCCESS") {
                event.getSource().set("v.disabled", true);
                component.set('v.recordCreated', true);
                // get the expire date (end date) to be displayed
                helper.getLatestExpireDate(component);
            } else {
                alert('A delivery complaint already exists for this day.');
            }
        });
        // Add the Apex action to the queue
        $A.enqueueAction(a);
    },
    setdeliveryIssueOptionSelected: function (component, event, helper) {
        // console.log('was: ' + component.get('v.deliveryIssueOptionSelected'));
        component.set('v.deliveryIssueOptionSelected', component.find('serviceIssue').get('v.value'));
        // console.log(' ... is now: ' + component.get('v.deliveryIssueOptionSelected'));
    },

    dateChanged: function (component, event, helper) {
        helper.validateDate(component, event, helper);
        //check if today is selected
        var today1 = $A.localizationService.formatDate(new Date(), "YYYY-M-DD");
        var today2 = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        var dateValue = component.get('v.dateSelected');
        var dateValueWithDay = new Date(dateValue);

        if (dateValue === today1 || dateValue === today2) {
            helper.lockTime(component);
            if (component.get('v.lockTime')) {
                helper.populateLockdown(component, event, helper);
            }
            else {
                var timeZone = new Date().toLocaleString("en-US", { timeZone: "America/New_York" })
                var estTime = new Date(timeZone);
                var redeliveryCutoff = new Date();

                /*Conditionally set the redelivery to ? on weekends or 8:30 AM on weekdays.*/
                if (estTime.getDay() === 0 || estTime.getDay() == 6) {
                    redeliveryCutoff.setHours(8);
                    redeliveryCutoff.setMinutes(30);
                }
                else {
                    redeliveryCutoff.setHours(8);
                    redeliveryCutoff.setMinutes(30);
                }
                if (redeliveryCutoff > estTime) {
                    helper.populateRedelivery(component, event, helper);
                }
                else {
                    helper.populateCredit(component, event, helper);
                }
            }
        }
        else {
            component.set('v.lockTime', false);
            helper.populateCredit(component);
        }
    },

    serviceDateChanged: function (component, event, helper) {
        helper.getDeliveryIssueList(component) 
                .then( deliveryIssueList => {
                    helper.setDeliveryIssueOptions(component, deliveryIssueList, true);
            });
    },

    issueSelectChanged: function (component, event, helper) {
        helper.getDeliveryIssueList(component) 
            .then( deliveryIssueList => {
                helper.setDeliveryIssueOptions(component, deliveryIssueList, false);
        });
    }
})