({
    
    // Fetch the CUSTOMER SALES from the Apex controller
    getTransactionLogList: function(component) {
        console.log('now in getloglist');

        // TODO : loop through filter by and removing the extra label;
        //          OR new list variable instead
        var recordId = component.get("v.recordId");
        var filterBy = '' + component.find("filterBy").get("v.value");
        var action = component.get("c.getTransactionLogs");
        console.log("filter values are: " + filterBy);
        console.log('Filter labels are: ' + component.find("filterBy").get("v.label"));
        
        // use new list variable instead of 'filterBy'
        action.setParams({"sobjId" : recordId, "filterType" : filterBy});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state == "SUCCESS") {
                console.log('Setting the TL List: ' + actionResult.getReturnValue());
                var retVal = actionResult.getReturnValue();
                //tlType match - count it and bind it here : no first_date - simply count it
                //var arr_filterby = filterBy.split(',');
                //console.log(arr_filterby);

                // To set two dates to two variables 
                var date2 = new Date(Date.now());
                console.log('date2: ' + date2);

                var countMap = new Map();
                var tlTypes = component.get("v.tlTypes");

                for(let elem of retVal){
                    var date1 = new Date(elem.First_Date);
                    //console.log('date1: ' + date1);
                    var timeDiffs = date2.getTime() - date1.getTime();
                    var dayDiffs = Math.ceil(timeDiffs / (1000 * 60 * 60 * 24));
                    
                    for(let thisType of tlTypes){
                        if( (elem.Category === thisType.value) && (dayDiffs <= 90) ) {
                            if (countMap.has(thisType.value)) {
                                countMap.set(thisType.value, countMap.get(thisType.value)+1 );
                            } else {
                                countMap.set(thisType.value, 1);
                            }
                           // console.log("retVal days output: " + elem.Category,elem.First_Date,dayDiffs);
                        }

                    }
                }
                for(let thisType of tlTypes){
					if(countMap.has(thisType.value)){
						thisType.label = thisType.value + " (" + countMap.get(thisType.value) + ") ";
					}
                }
				component.set("v.tlTypes", tlTypes);

                component.set("v.TransactionLogItemList", retVal);
                console.log('got what we need');
            }else if (state == "ERROR") {
                var errors = actionResult.getError();
                console.log('Error : ' + errors);
            }
        });
        $A.enqueueAction(action);
    },
    checkAllOptions: function(component, event, helper){
        var action = component.get("c.getTransactionTypes");
        var testOpts = [];       
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                console.log(retResponse);
                var initialOpts = [];
                var i;
                for (i = 0; i < retResponse.length; i++) {
                    testOpts.push(retResponse[i].Label);
                }
                component.set("v.tlSelectedTypes", testOpts);
                helper.getTransactionLogList(component);
   	
            }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },
    getTransactionTypeList:function(component){
        var action = component.get("c.getTransactionTypes");
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();
                console.log('retResonse: ' + retResponse);
                var opts = [];
                var i;
                for (i = 0; i < retResponse.length; i++) {
                    opts.push({'label': retResponse[i].Label, 'value': retResponse[i].Label});
                }
                component.set("v.tlTypes", opts);
                component.set("v.TypeSettings", retResponse);
            }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
    }
})