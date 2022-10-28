@isTest
public class AssignConsultantTest{
    
    @testsetup
    public static void testSetupData(){
        
        Account account = new Account();
        account.Name = 'Test Account';
        account.Family_Brand__c = 'Other';
        insert account;
        
        List<Contact> listConsultant = new List<Contact>();      
        for(Integer i=0; i<210; i++){
            listConsultant.add(new Contact(AccountId = account.Id,
                                           Consultant_Status__c = 'Active',
                                           LastName = 'Test Consultant',
                                           Phone = '+14158141829',
                                           CI_TY__c = true,
                                           Delphi__c = false,
                                           Envision__c = true,
                                           ISAC__c = false,
                                           SalesPro__c = true));
        }        
        insert listConsultant;
        
        List<Opportunity> listConsultantContact = new List<Opportunity>();
        for(Integer i=0; i<210; i++){
            listConsultantContact.add(new Opportunity(AccountId = account.Id,
                                                      Service_Start_Date__c = Date.valueOf('2016-02-12'),
                                                      Service_End_Date__c = Date.valueOf('2016-02-14'),    
                                                      Name = 'Test Consultant Contact',
                                                      CloseDate = Date.valueOf('2017-03-21'),
                                                      StageName = 'Needs Analysis'));   
        }
        
        insert listConsultantContact;       
        
    }    
    
    public static testmethod void testAssignConsultantSingleRecord(){
        
        Contact consultant = [SELECT Id FROM Contact LIMIT 1];
        Opportunity consultantContact = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Eligible_Consultant__c eligibleConsultant = new Eligible_Consultant__c();
        eligibleConsultant.Consultant__c = consultant.Id;
        eligibleConsultant.Opportunity__c = consultantContact.Id;
        insert eligibleConsultant; 
        
        eligibleConsultant.Interested__c = 'Yes';
        eligibleConsultant.Status__c = 'Selected';
        update eligibleConsultant;
        
        Test.stopTest();
        
        eligibleConsultant = [SELECT Status__c, Consultant__c FROM Eligible_Consultant__c WHERE Id = :eligibleConsultant.Id];
        System.assertEquals('Selected', eligibleConsultant.Status__c);
        
        consultantContact = [SELECT Consultant_Assigned__c FROM Opportunity WHERE ID = :consultantContact.Id];     
        System.assertEquals(eligibleConsultant.Consultant__c , consultantContact.Consultant_Assigned__c); 
    }  
    
    public static testmethod void testAssignConsultantBulkRecord(){
        
        List<Contact> listConsultant = [SELECT Id FROM Contact];
        List<Opportunity> listConsultantContact = [SELECT Id FROM Opportunity];
        
        Test.startTest();
        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        for(Integer i=0; i < 210; i++){
            listEligibleConsultant.add( new Eligible_Consultant__c(Consultant__c = listConsultant[i].Id,
                                                                   Opportunity__c = listConsultantContact[i].Id));
        }     
        insert listEligibleConsultant; 
        
        for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultant){
            eligibleConsultant.Interested__c = 'Yes';
            eligibleConsultant.Status__c = 'Selected';
        }               
        update listEligibleConsultant;        
        Test.stopTest();
        
        Map<Id, Opportunity> mapConsultantContact = new Map<Id, Opportunity>([SELECT Id,Consultant_Assigned__c 
                                                                              FROM Opportunity]); 
        listEligibleConsultant = [SELECT Status__c, Consultant__c, Opportunity__c FROM Eligible_Consultant__c];        
        
        for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultant){
            System.assertEquals('Selected', eligibleConsultant.Status__c);
            System.assertEquals(eligibleConsultant.Consultant__c , mapConsultantContact.get(eligibleConsultant.Opportunity__c).Consultant_Assigned__c); 
        }          
    }  
    
    public static testmethod void testAssignConsultantSingleRecordNegative(){
        
        Contact consultant = [SELECT Id FROM Contact LIMIT 1];
        Opportunity consultantContact = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        Eligible_Consultant__c eligibleConsultant = new Eligible_Consultant__c();
        eligibleConsultant.Consultant__c = consultant.Id;
        eligibleConsultant.Opportunity__c = consultantContact.Id;
        insert eligibleConsultant; 
        
        eligibleConsultant.Interested__c = 'Yes';
        eligibleConsultant.Status__c = 'Selected';
        update eligibleConsultant;    
        
        consultantContact = [SELECT Consultant_Assigned__c FROM Opportunity WHERE ID = :consultantContact.Id];     
        System.assertEquals(eligibleConsultant.Consultant__c , consultantContact.Consultant_Assigned__c);   
        
        eligibleConsultant.Interested__c = 'No';
        eligibleConsultant.Status__c = 'Selected';
        update eligibleConsultant;
        
        Test.stopTest();
        
        eligibleConsultant = [SELECT Status__c, Consultant__c FROM Eligible_Consultant__c WHERE Id = :eligibleConsultant.Id];
        //System.assertEquals('Consultant Turned Down', eligibleConsultant.Status__c);
        
        consultantContact = [SELECT Consultant_Assigned__c FROM Opportunity WHERE ID = :consultantContact.Id];     
        System.assertEquals(null , consultantContact.Consultant_Assigned__c); 
    }  
}