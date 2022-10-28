@isTest
public class OverlappingBookedDatesTest{
    
    @testSetup
    public static void testData(){
        
        RecordType consultantAccount = [SELECT Id FROM RecordType WHERE Name = 'Consultant Account' AND SobjectType = 'Account'];
        Account testAccount = new Account(Name = 'Test Account',
                                          RecordTypeId = consultantAccount.Id);
        insert testAccount;
        
        RecordType consultants = [SELECT Id FROM RecordType WHERE Name = 'Consultants' AND SobjectType = 'Contact'];
        Contact testContact1 = new Contact(AccountId = testAccount.Id,
                                           LastName = 'Test Contact-1',
                                           RecordTypeId = consultants.Id);    
        insert testContact1;  
        
        Contact testContact2 = new Contact(AccountId = testAccount.Id,
                                           LastName = 'Test Contact-2',
                                           RecordTypeId = consultants.Id);    
        insert testContact2; 
        
        List<Consultant_Block_Out_Dates__c> listBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        
        Consultant_Block_Out_Dates__c testBlockOutDates1 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact1.Id,
                                                                                             Not_Available_Start_Date__c = Date.valueOf('2016-01-01'),
                                                                                             Not_Available_End_Date__c = Date.valueOf('2016-01-10'),
                                                                                             Not_Available_Details__c = 'Test Block Out Dates - 1');
        listBlockOutDates.add(testBlockOutDates1);
        
        Consultant_Block_Out_Dates__c testBlockOutDates2 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact2.Id,
                                                                                             Not_Available_Start_Date__c = Date.valueOf('2016-02-01'),
                                                                                             Not_Available_End_Date__c = Date.valueOf('2016-02-10'),
                                                                                             Not_Available_Details__c = 'Test Block Out Dates - 2');
        listBlockOutDates.add(testBlockOutDates2);
        
        insert listBlockOutDates;
        
        List<Opportunity> listValidBookingDates = new List<Opportunity>();
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        listValidBookingDates.add(new Opportunity(Name = 'Test Opportuntiy1',
                                                  AccountId = accountId,
                                                  Primary_Contact__c = testContact1.Id,                                               
                                                  StageName = 'Tentative',
                                                  CloseDate = Date.today().addYears(1),
                                                 // Consultant_Assigned__c = testContact1.Id,
                                                  Service_Start_Date__c = Date.valueOf('2016-01-25'),
                                                  Service_End_Date__c = Date.valueOf('2016-01-28')));
        
        listValidBookingDates.add(new Opportunity(Name = 'Test Opportuntiy2',
                                                  AccountId = accountId,
                                                  Primary_Contact__c = testContact2.Id,                                               
                                                  StageName = 'Tentative',
                                                  CloseDate = Date.today().addYears(1),
                                                 // Consultant_Assigned__c = testContact2.Id,
                                                  Service_Start_Date__c = Date.valueOf('2016-02-25'),
                                                  Service_End_Date__c = Date.valueOf('2016-02-28')));
        insert listValidBookingDates;   

        Eligible_Consultant__c testEligibleConsultant = new Eligible_Consultant__c();
        testEligibleConsultant.Consultant__c = testContact1.Id;
        testEligibleConsultant.Opportunity__c = listValidBookingDates[0].Id;
        testEligibleConsultant.Interested__c = 'Yes';
        testEligibleConsultant.Status__c = 'Selected';
        insert testEligibleConsultant;     
        
    }
    
     public static testmethod void testSingleOpportunityUpdate(){
     
          Id consultantContactId = [SELECT Id FROM Contact
                                  WHERE LastName = 'Test Contact-1'
                                  LIMIT 1].Id;
                                  
          Opportunity opportunity = [SELECT Id,Consultant_Assigned__c  FROM Opportunity WHERE Name = 'Test Opportuntiy2'];
          opportunity.Consultant_Assigned__c  = consultantContactId;
          
          UPDATE opportunity;
          

     }
    
    public static testmethod void testSingleRecordInsert(){
        
        Id consultantContactId = [SELECT Id FROM Contact
                                  WHERE LastName = 'Test Contact-1'
                                  LIMIT 1].Id;
        
        Id testOpp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportuntiy2' LIMIT 1].Id;

        Eligible_Consultant__c testEligibleConsultant = new Eligible_Consultant__c();
        testEligibleConsultant.Consultant__c = consultantContactId;
        testEligibleConsultant.Opportunity__c = testOpp1Id;
        testEligibleConsultant.Interested__c = 'Yes';
        testEligibleConsultant.Status__c = 'Selected';        

        Test.startTest();
        try{
            insert testEligibleConsultant;
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 'Consultant Not Available.' + ': []');            
        }
        Test.stopTest();
        
    } 
    
    public static testmethod void testSingleRecordUpdate(){
        
        Id consultantContactId = [SELECT Id FROM Contact
                                  WHERE LastName = 'Test Contact-1'
                                  LIMIT 1].Id;
        
        Id testOpp1Id = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportuntiy2' LIMIT 1].Id;

        Eligible_Consultant__c testEligibleConsultant = new Eligible_Consultant__c();
        testEligibleConsultant.Consultant__c = consultantContactId;
        testEligibleConsultant.Opportunity__c = testOpp1Id;
        testEligibleConsultant.Interested__c = 'Yes';
        testEligibleConsultant.Status__c = 'Selected'; 
        insert testEligibleConsultant; 
        
        Test.startTest();
        testEligibleConsultant = [SELECT Status__c
                                  FROM Eligible_Consultant__c WHERE Id = :testEligibleConsultant.Id];
        //testEligibleConsultant.Opportunity__r.Service_Start_Date__c = Date.valueOf('2016-01-05');
        //testEligibleConsultant.Opportunity__r.Service_End_Date__c = Date.valueOf('2016-01-08');
        testEligibleConsultant.Status__c = 'Eligible'; 
        
        try{
            update testEligibleConsultant;
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Update failed. First exception on row 0 with id ' + testEligibleConsultant.Id + '; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 'Consultant Not Available.' + ': []');            
        }
        
        Test.stopTest();        
    }
    
    public static testmethod void testBulkRecordInsert(){        
     
        Id testAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        RecordType consultants = [SELECT Id FROM RecordType WHERE Name = 'Consultants' AND SobjectType = 'Contact'];

        List<Contact> listConsultantContact = new List<Contact>();
        for(integer i=0; i<208; i++){
          listConsultantContact.add(new Contact(AccountId = testAccountId,
                                               LastName = 'Test Contact-' + (i+3),
                                               RecordTypeId = consultants.Id));
        }      
        insert listConsultantContact;

        listConsultantContact = [SELECT Id FROM Contact ORDER BY LastName];
                  
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        
        for(integer count=0;count < 209; count++){
          listEligibleConsultant.add(new Eligible_Consultant__c(
                                  Consultant__c = listConsultantContact[count+1].Id,
                                  Opportunity__c = opportunityId,
                                  Interested__c = 'Yes',
                                  Status__c = 'Selected'));           
        }
        
        Test.startTest();
        try{
            insert listEligibleConsultant;
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');            
        }
        Test.stopTest();
    }
    
    public static testmethod void testBulkRecordUpdate(){
    
        Id testAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        RecordType consultants = [SELECT Id FROM RecordType WHERE Name = 'Consultants' AND SobjectType = 'Contact'];

        List<Contact> listConsultantContact = new List<Contact>();
        for(integer i=0; i<208; i++){
          listConsultantContact.add(new Contact(AccountId = testAccountId,
                                               LastName = 'Test Contact-' + (i+3),
                                               RecordTypeId = consultants.Id));
        }      
        insert listConsultantContact;

        listConsultantContact = [SELECT Id FROM Contact ORDER BY LastName];
                  
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        
        for(integer count=0;count < 209; count++){
          listEligibleConsultant.add(new Eligible_Consultant__c(
                                  Consultant__c = listConsultantContact[count+1].Id,
                                  Opportunity__c = opportunityId,
                                  Interested__c = 'Yes',
                                  Status__c = 'Selected'));           
        }

        insert listEligibleConsultant;
        
        listEligibleConsultant = [SELECT Status__c FROM Eligible_Consultant__c                                   
                                  ORDER BY Consultant__r.LastName];
                                  
        System.assertEquals(210, listEligibleConsultant.size());
        
        List<Eligible_Consultant__c> listUpdateValidBookingDates = new List<Eligible_Consultant__c>();       
        
        Test.startTest();
        for(integer count=0;count < 210; count++){
            listUpdateValidBookingDates.add(new Eligible_Consultant__c(Id = listEligibleConsultant[count].Id,
                                                            Status__c = 'Eligible'));      
        }
        try{
            update listUpdateValidBookingDates;
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');            
        }
        Test.stopTest();
    }
}