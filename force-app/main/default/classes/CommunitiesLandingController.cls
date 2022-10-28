/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        User u;
        Profile userProfile;
        PageReference userSetupPage;
        try{
            u = [SELECT Id, isNewUser__c, ContactId FROM User WHERE Id=:userinfo.getuserid()];
            userProfile = [SELECT Id, name FROM Profile WHERE UserLicense.Name = 'Customer Community' AND name LIKE '%Consultant%'];
        } catch(Exception exp) { System.debug('fetch Data Exception :: ' + exp.getMessage()); }
        system.debug('User :: ' + u);
        if(u != null) {
            if(u.isNewUser__c && userinfo.getprofileid() == userProfile.id) {
                userSetupPage = Page.CH_UserSetupPage;
                userSetupPage.setRedirect(true);
            } else {
                userSetupPage = Network.communitiesLanding();
            }
        }        
        return userSetupPage;
    }
    
    public CommunitiesLandingController() {}
}