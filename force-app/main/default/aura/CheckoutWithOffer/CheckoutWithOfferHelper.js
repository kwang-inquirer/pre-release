({
    handleSuccess : function(component) {
        var finishFlow = component.get('v.finishFlow');
        if (finishFlow) {
            var navigate = component.get("v.navigateFlow");
            navigate("FINISH");
        }
    }
})