({
    getSubscription : function (component) {
        console.log(component.get("v.recordId"))
        return new Promise((resolve, reject) => {
            var action = component.get("c.fetchSubscription");
            action.setParams({ "subId": component.get("v.recordId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('response state : ' + state);
                console.log('response.getReturnValue(): ' + JSON.stringify(response.getReturnValue()));
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    console.log('Problem getting Subscription data, response state : ' + state);
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },
    getOfferProducts : function (component) {
        console.log('getoffprod');
        return new Promise((resolve, reject) => {
            var action = component.get("c.fetchOfferProducts");
            action.setParams({ "subId": component.get("v.recordId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('response state : ' + state);
                console.log('response.getReturnValue(): ' + JSON.stringify(response.getReturnValue()));
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else {
                    console.log('Problem getting offer product data, response state : ' + state);
                    reject();
                }
            });
            $A.enqueueAction(action);
        });
    },
    calculate : function (component) {
        console.log(component.get('v.selectedOfferProducts'));
        var params = {
            subscriptionId: component.get('v.recordId'),
            startDate: component.get('v.startDate'),
            endDate: component.get('v.endDate'),
            offerProductIds: component.get('v.selectedOfferProducts')
        };
        return new Promise((resolve, reject) => {
            var action = component.get("c.calculate");
            action.setParams(params);
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('response state : ' + state);
                console.log('response.getReturnValue(): ' + JSON.stringify(response.getReturnValue()));
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
    }
})