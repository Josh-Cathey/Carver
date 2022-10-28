@isTest
public class TwilioRecieveSMSControllerTest{
    
    @testsetup
    public static void testSetupData(){
        Account account = new Account();
        account.Name = 'Test Account';
        account.Family_Brand__c = 'Other';
        insert account;
        
        Contact consultant = new Contact();        
        consultant.AccountId = account.Id;
        consultant.LastName = 'Test Consultant';
        consultant.Phone = '+14158141829';
        insert consultant;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.AccountId = account.Id;
        opp.Primary_Contact__c = consultant.Id;
        opp.CloseDate = Date.valueOf('2017-03-21');
        opp.StageName = 'Needs Analysis';
        opp.Service_Start_Date__c = Date.valueOf('2016-04-12');
        opp.Service_End_Date__c = Date.valueOf('2016-04-14');  
        insert opp;
        
        Eligible_Consultant__c eligibleConsultant = new Eligible_Consultant__c();
        eligibleConsultant.Consultant__c = consultant.Id;
        eligibleConsultant.Opportunity__c = opp.Id;
        insert eligibleConsultant; 
    }
    
    public static testmethod void positiveTestReplyYes(){
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('From', '+14158141829');
        ApexPages.currentPage().getParameters().put('To', '+14158141830');
        ApexPages.currentPage().getParameters().put('Body', 'Yes');      
        
        TwilioRecieveSMSController controller = new TwilioRecieveSMSController();
        controller.init();
        
        Eligible_Consultant__c eligibleConsultant = [SELECT Interested__c FROM Eligible_Consultant__c LIMIT 1];        
        System.assertEquals('Yes',eligibleConsultant.Interested__c);
        System.assertEquals('Thank you for your reply.', controller.strReplyMsg);
    }
    
    public static testmethod void positiveTestReplyNo(){
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('From', '+14158141829');
        ApexPages.currentPage().getParameters().put('To', '+14158141830');
        ApexPages.currentPage().getParameters().put('Body', 'No');      
        
        TwilioRecieveSMSController controller = new TwilioRecieveSMSController();
        controller.init();
        
        Eligible_Consultant__c eligibleConsultant = [SELECT Interested__c FROM Eligible_Consultant__c LIMIT 1];        
        System.assertEquals('No',eligibleConsultant.Interested__c);
        System.assertEquals('Thank you for your reply.', controller.strReplyMsg);
    }
    
    public static testmethod void negativeTestNoEligibleConsultant(){
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('From', '+14158141831');
        ApexPages.currentPage().getParameters().put('To', '+14158141830');
        ApexPages.currentPage().getParameters().put('Body', 'Yes');      
        
        TwilioRecieveSMSController controller = new TwilioRecieveSMSController();
        controller.init();
        
        Eligible_Consultant__c eligibleConsultant = [SELECT Interested__c FROM Eligible_Consultant__c LIMIT 1];        
        System.assertEquals(null,eligibleConsultant.Interested__c);
        System.assertEquals('Consultant with Phone(+14158141831) not found.', controller.strReplyMsg);
    }
    
    public static testmethod void negativeTestInvalidReply(){
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('From', '+14158141829');
        ApexPages.currentPage().getParameters().put('To', '+14158141830');
        ApexPages.currentPage().getParameters().put('Body', 'xyz');      
        
        TwilioRecieveSMSController controller = new TwilioRecieveSMSController();
        controller.init();
        
        Eligible_Consultant__c eligibleConsultant = [SELECT Interested__c FROM Eligible_Consultant__c LIMIT 1];        
        System.assertEquals(null,eligibleConsultant.Interested__c);
        System.assertEquals('Invalid reply!!!.\nPlease reply with YES or NO.', controller.strReplyMsg);
    }
}