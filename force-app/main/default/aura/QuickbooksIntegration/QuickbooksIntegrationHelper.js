({
    authorizeHelper : function(component, event, helper) {
        let requestoAuthURL = 'https://appcenter.intuit.com/connect/oauth2?response_type=code&client_id=' 
            + component.get('v.clientKey') 
            + '&redirect_uri=' 
            + component.get('v.redirectURI') 
            + '&scope=' 
            + component.get('v.scope') 
            + '&state=security_token%3D138r5719ru3e1%26url%3Dhttps://www.mydemoapp.com/oauth-redirect';

        console.log('requestoAuthURL>>>>', requestoAuthURL);

        var action1 = component.get('c.saveKeyAndSecret');
        // var sURL = window.location.href;
        // var accescode = sURL.split('code=')[1];

        action1.setParams({
            clientId : component.get('v.clientKey'),
            clientSecret : component.get('v.clientSecret'),
        });

        action1.setCallback(this, function (data) {
            var state = data.getState();
            console.log("State>>", state);

            if (state == 'SUCCESS') {
                let retVal = data.getReturnValue();
                console.log("retVal>>", retVal);
                }
        }); $A.enqueueAction(action1);
        window.location.href = requestoAuthURL;
    },

    completeAuthHelper : function(component, event, helper) {
        try {
            var action = component.get('c.getAuthDone');
            var sURL = window.location.href;
            var accescode = sURL.split('code=')[1];
            var comId = sURL.split('realmId=')[1];
            component.set('v.companyId',comId)
            console.log('companyId>>>>>',comId);
            action.setParams({
                authCodeFromURL : accescode.substr(0,accescode.indexOf('&state')),
                redirect_URI : component.get('v.redirectURI')
            });

            action.setCallback(this, function (data) {
                var state = data.getState();
                console.log("State>>", state);
                if (state == 'SUCCESS') {
                    var retVal = data.getReturnValue();
                    console.log("retVal>>", retVal);
                    if(retVal){
                        component.set('v.isAuth',true);
                    }
                    else{
                        console.log('An error occurred');
                    }
                    }
            }); $A.enqueueAction(action);
        }
        catch (error) {
            console.log(error);
        }
    }
})