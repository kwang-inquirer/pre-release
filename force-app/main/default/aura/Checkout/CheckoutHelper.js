({
    handleInit: function (component) {
        var email = component.get('v.email');
        var pianoId = component.get('v.pianoId');
        if (!pianoId) {
            component.set('v.pianoId', this.getUrlParameter('subscriberId'));
        }
        if (!email) {
            component.set('v.email', this.getUrlParameter('email'));
        }
    },
    getUrlParameter: function (name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results && results[1] || '';
    }
})