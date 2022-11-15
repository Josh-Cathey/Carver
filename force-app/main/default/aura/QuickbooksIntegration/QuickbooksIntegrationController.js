({
    doInit : function(component, event, helper) {
        //Prod -> uncomment if deployed to production
        //component.set('v.redirectURI', 'https://carver.lightning.force.com/c/QuickbooksAccessRefresh.app');
        
        //Sandbox
        component.set('v.redirectURI', 'https://carver--partialtf.sandbox.lightning.force.com/c/QuickbooksAccessRefresh.app');
        
        console.log('redirectUri>>>>', component.get('v.redirectURI'));
        var sURL = window.location.href;
        if(sURL.split('code=')[1] != null) {
            component.set('v.isNotAuth', false);
            helper.completeAuthHelper(component, event, helper);
        }
        else {
            component.set('v.isNotAuth', true);
            component.set('v.isAuth', false);
        }
    },

    authorizeController : function(component, event, helper) {
        helper.authorizeHelper(component, event, helper);
    },

})