@isTest
public class JopOpeningAlertResponseControllerTest{
	
    @testsetup
    public static void testDataSetup(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testConsultant = new Contact();
        testConsultant.LastName = 'Test Consultant';
        testConsultant.Email = 'test@test.com';
        testConsultant.Phone = '9876543210';
        insert testConsultant;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Name = 'Test Opp';
        testOpp.CloseDate = Date.today().addDays(4);
        testOpp.AccountId = testAccount.Id;
        testOpp.Primary_Contact__c = testConsultant.Id;
        testOpp.StageName = 'Tentative';        
        insert testOpp;         
    }
    
    public static testmethod void testPositiveData(){
        
        Contact testConsultant = [SELECT Id FROM Contact LIMIT 1];
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Eligible_Consultant__c testEligibleConsultant = new Eligible_Consultant__c();
        testEligibleConsultant.Consultant__c = testConsultant.Id;
        testEligibleConsultant.Opportunity__c = testOpp.Id;        
        insert testEligibleConsultant;
        
        PageReference jobOpeningAlertRespPage = Page.JobOpeningAlertResponse;
    	Test.setCurrentPage(jobOpeningAlertRespPage);  
        ApexPages.currentPage().getParameters().put('id', testEligibleConsultant.Id);
        ApexPages.currentPage().getParameters().put('reply', 'Yes');        
        
        Test.startTest();        
        JopOpeningAlertResponseController.updateEligibleConsultant(testEligibleConsultant.Id, 'Yes');        
        Test.stopTest();
        
        testEligibleConsultant = [SELECT Interested__c FROM Eligible_Consultant__c LIMIT 1];
        System.assertEquals('Yes', testEligibleConsultant.Interested__c);
    }
}