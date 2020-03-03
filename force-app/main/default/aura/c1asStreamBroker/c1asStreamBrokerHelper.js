({
    bootstrapCometD : function(component) {
        console.log('here');
        var userAction = component.get("c.getUserId");
        userAction.setCallback(this, function (b) {
            var uid = b.getReturnValue();
            console.log('onCometdLoaded: Got user ID=' + uid);
            component.set('v.user', uid);
        });
        $A.enqueueAction(userAction);
        
        var action = component.get("c.retrieveSesstionId");
        
        action.setCallback(this, function(response){
            console.log('here2');
            var state = response.getState();
            
            if(state === "SUCCESS") {
                console.log('here3');
                console.log(response.getReturnValue());
                component.set("v.sessionId", response.getReturnValue());
                
                var cometdUrl = window.location.protocol+'//'+window.location.hostname+'/cometd/40.0/';
                console.log('connectCometd: cometdUrl= ' + cometdUrl);
                
                // Connect to the CometD endpoint
                $.cometd.init({
                    //url: '/cometd/40.0',
                    url: cometdUrl,
                    requestHeaders: { Authorization: component.get("v.sessionId")}
                });
                
                // Subscribe to a topic. JSON-encoded update will be returned
                // in the callback
                console.log('subscribe');
                $.cometd.subscribe('/topic/' + component.get('v.user'), function(message) {
                    //console.log('message');
                    console.log(message);
                    //console.log(message.data.sobject.message__c);
                    //var subject = message.data.sobject.message__c;
                    //var status = message.data.sobject.message__c;
                    
                    //component.set("v.subject", subject);
                    //component.set("v.status", status);
                    //---------------stevie test added pop here---------------------------------
                    console.log('before workspaceAPI');		
                    
                    var workspaceAPI = component.find("workspace");
                    console.log('workspace found');
                    
                    workspaceAPI.openTab({
                        url: message.data.sobject.message__c,
                        focus: true
                    }).then(function(response) {
                        console.log('before getTab');	
                        workspaceAPI.getTabInfo({
                            tabId: response
                        }).then(function(tabInfo) {
                            console.log("The url for this tab is: " + tabInfo.url);
                        });
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    console.log('here4');	
                    //-------------------------------------------------------------
                });
            }
            console.log('here4');
        });
        $A.enqueueAction(action);
        console.log('here5');
    }
})