/**
 * An apex page controller that exposes the site MyHealthInsurance page functionality for display data
 */
 
@IsTest global class CH_UserSetupPageControllerTest {
    @testSetup
    public static void testDataSetup() {        
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(AccountId = testAccount.Id,
                                      LastName = 'Test Contact');
        insert testContact; 
    }
    
    global static testmethod void testCH_UserSetupPageController() {

        Contact testContact = [SELECT Id FROM Contact LIMIT 1];        
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='Community - Consultant']; 
        System.debug('testContact  :: ' + testContact );

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
        
        insert communityUser;
        Attachment att = new Attachment(ParentId = testContact.id, Name = 'test', Body=Blob.valueOf('test'));
        insert att;
        
        CH_UserSetupPageController.doUploadAttachment(testContact.id,'testBodyfghgkjhgjh','testAttchmentName','','profile','0',false,true);
            
        String AttId = [SELECT Id FROM Attachment LIMIT 1].Id;
        
        CH_UserSetupPageController.doUploadAttachment(communityUser.ContactId,'testBodyfghgkjhgjh','testAttchmentName',AttId,'profile','0',true,false);
        CH_UserSetupPageController CHU;
        System.runAs(communityUser) {
            
            CHU = new CH_UserSetupPageController();
            
            //Call "getDelphiStandard()" method
            List<SelectOption> delphiStandardList  = CHU.getDelphiStandard();
            
            System.assert(CHU.contactObj != null);
        }    
            
            CHU.listBrands = new List<Brands__c>();
            CHU.listJobExperiences = new List<Job_Experience__c>();
            
            CHU.addNewBrand();
            CHU.addNewBrand();           

            
            PageReference pageRef = Page.CH_UserSetupPage;
            pageRef.getParameters().put('bIndex','1');
            Test.setCurrentPage(pageRef);
            CHU.removeBrand();

            
            CHU.addNewJobExperience();
            CHU.addNewJobExperience();
            
            pageRef = Page.CH_UserSetupPage;
            pageRef.getParameters().put('jeIndex','1');
            Test.setCurrentPage(pageRef);
            CHU.removeJobExperience();            

            pageRef = Page.CH_UserSetupPage;
            pageRef.getParameters().put('bUpdateIndex','1');
            pageRef.getParameters().put('listBrands','');
            Test.setCurrentPage(pageRef);
            CHU.setDependentBrands();
            
            CH_UserSetupPageController.getDependentBrands('Choice', '1', '');            
            
            
            pageRef = Page.CH_UserSetupPage;
            pageRef.getParameters().put('langs','');
            pageRef.getParameters().put('ProfileImgURL','test');
            Test.setCurrentPage(pageRef);
            
            CHU.listBrands[0].Family_of_Brands__c = 'Marriott';
            CHU.listBrands[0].Other_Brand__c = 'testOther';
            CHU.listJobExperiences[0].Hotel_Property_Name__c = 'TestHotel';
            CHU.listJobExperiences[0].Property_City__c = 'TestCity';
            CHU.saveAllData();
        //}
    }    
}