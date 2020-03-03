({
    init : function(component, event, helper) {
        console.log('init');
        try {
            if (window.recurly) {
                console.log('configure recurly');
                console.log(window.recurly);
                window.recurly.configure('ewr1-ca9Cx5DhoeJDPzxvZu0iJM');
                console.log ('recurly not found');
            } else {
                console.log ('recurly not found');
            }
        } catch (e) {
            console.log(e);
        }
        console.log('finish init');
    }   
})