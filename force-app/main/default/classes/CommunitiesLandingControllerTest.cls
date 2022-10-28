/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
@IsTest public with sharing class CommunitiesLandingControllerTest {
    @IsTest public static void testCommunitiesLandingController() {
        // Instantiate a new controller with all parameters in the page
        CommunitiesLandingController controller = new CommunitiesLandingController();
        controller.forwardToStartPage();
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        Contact testContact = new Contact(AccountId = testAccount.Id,
                                      LastName = 'Test Contact');
        insert testContact;
        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Community - Consultant'];
        
        User communityUser = new User( email='genelia.dsouza@gmail.com',
                profileid = portalProfile.Id, 
                UserName='genelia.dsouza@gmail.com', 
                Alias = 'GDS',
                TimeZoneSidKey='America/New_York',
                EmailEncodingKey='ISO-8859-1',
                LocaleSidKey='en_US', 
                LanguageLocaleKey='en_US',
                ContactId = testContact.Id,
                PortalRole = 'Manager',
                FirstName = 'Genelia',
                LastName = 'Dsouza');
//        User communityUser = [SELECT Id, isNewUser__c, ContactId FROM User WHERE profile.Name = 'Community - Consultant' AND isNewUser__c = true LIMIT 1];
        System.runAs(communityUser){
            controller.forwardToStartPage();
        }
      }
}