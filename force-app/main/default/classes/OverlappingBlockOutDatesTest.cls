@isTest
public class OverlappingBlockOutDatesTest {
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

        List<Opportunity> listBookedDates = new List<Opportunity>();
        
        Opportunity testOpp1 = new Opportunity(Name = 'Test Opportuntiy1',
                                                                                     AccountId = testAccount.Id,
                                                                                     Primary_Contact__c = testContact1.Id,                                               
                                                                                     StageName = 'Tentative',
                                                                                     CloseDate = Date.today().addYears(1),
                                                                                     //Consultant_Assigned__c = testContact1.Id,
                                                                                     Service_Start_Date__c = Date.valueOf('2016-01-01'),
                                                                                     Service_End_Date__c = Date.valueOf('2016-01-10'));
        listBookedDates.add(testOpp1);
        
        Opportunity testOpp2 = new Opportunity(Name = 'Test Opportuntiy2',
                                                                                     AccountId = testAccount.Id,
                                                                                     Primary_Contact__c = testContact2.Id,
                                                                                     StageName = 'Tentative',
                                                                                     CloseDate = Date.today().addYears(1),
                                                                                     //Consultant_Assigned__c = testContact2.Id,
                                                                                     Service_Start_Date__c = Date.valueOf('2016-02-01'),
                                                                                     Service_End_Date__c = Date.valueOf('2016-02-10'));
        listBookedDates.add(testOpp2);
        
        insert listBookedDates;

        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        
        Eligible_Consultant__c testEligibleConsultant1 = new Eligible_Consultant__c();
        testEligibleConsultant1.Consultant__c = testContact1.Id;
        testEligibleConsultant1.Opportunity__c = testOpp1.Id;
        testEligibleConsultant1.Interested__c = 'Yes';
        testEligibleConsultant1.Status__c = 'Eligible';
        listEligibleConsultant.add(testEligibleConsultant1);

        Eligible_Consultant__c testEligibleConsultant2 = new Eligible_Consultant__c();
        testEligibleConsultant2.Consultant__c = testContact2.Id;
        testEligibleConsultant2.Opportunity__c = testOpp2.Id;
        testEligibleConsultant2.Interested__c = 'Yes';
        testEligibleConsultant2.Status__c = 'Selected';
        listEligibleConsultant.add(testEligibleConsultant2);

        insert listEligibleConsultant;
        
        List<Consultant_Block_Out_Dates__c> listBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        
        Consultant_Block_Out_Dates__c testBlockOutDates1 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact1.Id,
                                                                                                                                                                                 Not_Available_Start_Date__c = Date.valueOf('2016-01-25'),
                                                                                                                                                                                 Not_Available_End_Date__c = Date.valueOf('2016-01-28'),
                                                                                                                                                                                 Not_Available_Details__c = 'Test Block Out Dates - 1');
        listBlockOutDates.add(testBlockOutDates1);
        
        Consultant_Block_Out_Dates__c testBlockOutDates2 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact2.Id,
                                                                                                                                                                                 Not_Available_Start_Date__c = Date.valueOf('2016-02-25'),
                                                                                                                                                                                 Not_Available_End_Date__c = Date.valueOf('2016-02-28'),
                                                                                                                                                                                 Not_Available_Details__c = 'Test Block Out Dates - 2');
        listBlockOutDates.add(testBlockOutDates2);
        
        insert listBlockOutDates;
        
    }
    
    public static testmethod void testSingleRecord(){
        
        Id consultantContactId = [SELECT Id FROM Contact
                                                            WHERE LastName = 'Test Contact-1'
                                                            LIMIT 1].Id;
        
        Consultant_Block_Out_Dates__c testBlockOutDates1 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = consultantContactId,
                                                                                                                                                                                 Not_Available_Start_Date__c = Date.valueOf('2016-01-08'),
                                                                                                                                                                                 Not_Available_End_Date__c = Date.valueOf('2016-01-12'),
                                                                                                                                                                                 Not_Available_Details__c = 'Test Block Out Dates - 1');
        
        Test.startTest();
        try{
            insert testBlockOutDates1;
        }catch(DmlException e){
                        //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 
                'Consultant Not Available.' + ': []');            
        }
        Test.stopTest();        
    }
    
    public static testmethod void testSingleRecordUpdate(){
        
        Id consultantContactId = [SELECT Id FROM Contact
        WHERE LastName = 'Test Contact-1'
        LIMIT 1].Id;
        
        Consultant_Block_Out_Dates__c testBlockOutDates1 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = consultantContactId,
                                                                                                                                                                                    Not_Available_Start_Date__c = Date.valueOf('2016-01-15'),
                                                                                                                                                                                    Not_Available_End_Date__c = Date.valueOf('2016-01-18'),
                                                                                                                                                                                    Not_Available_Details__c = 'Test Block Out Dates - 1');
        insert testBlockOutDates1;        
        
        Test.startTest();
        testBlockOutDates1 = [SELECT Not_Available_Start_Date__c, Not_Available_End_Date__c FROM Consultant_Block_Out_Dates__c WHERE Id = :testBlockOutDates1.Id];
        testBlockOutDates1.Not_Available_Start_Date__c = Date.valueOf('2016-01-05');
        testBlockOutDates1.Not_Available_End_Date__c = Date.valueOf('2016-01-08');
        
        try{
            update testBlockOutDates1;
        }catch(DmlException e){
                        //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Update failed. First exception on row 0 with id ' + testBlockOutDates1.Id + '; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 'Consultant Not Available.' + ': []');            
        }        
        Test.stopTest();        
    }
    
    public static testmethod void testBulkRecordInsert(){
        
        List<Contact> listConsultantContact = [SELECT Id FROM Contact
                                                                                     WHERE LastName IN ('Test Contact-1','Test Contact-2')];        
        Id consultantContactId;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        
        List<Consultant_Block_Out_Dates__c> listValidBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        
        for(integer count=0;count < 210; count++){
            if(count < 105)
                consultantContactId = listConsultantContact[0].Id;
            else
                consultantContactId = listConsultantContact[1].Id;
            
            listValidBlockOutDates.add(new Consultant_Block_Out_Dates__c(Consultant_Contact__c = consultantContactId,
                                                                                                                                        Not_Available_Start_Date__c = Date.valueOf('2016-01-02'),
                                                                                                                                        Not_Available_End_Date__c = Date.valueOf('2016-01-12'),
                                                                                                                                        Not_Available_Details__c = 'Test Block Out Dates - 1'));      
        }
        
        Test.startTest();
        try{
            insert listValidBlockOutDates;
        }catch(DmlException e){
                        //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');            
        }
        Test.stopTest();
    }
    
    public static testmethod void testBulkRecordUpdate(){
        
        List<Contact> listConsultantContact = [SELECT Id FROM Contact
        WHERE LastName IN ('Test Contact-1','Test Contact-2')];        
        Id consultantContactId;
        Id accountId = [SELECT Id FROM Account LIMIT 1].Id;
        Date startDate = Date.valueOf('2016-03-01');
        Date endDate = Date.valueOf('2016-03-01');
        
        List<Consultant_Block_Out_Dates__c> listValidBlockOutDates = new List<Consultant_Block_Out_Dates__c>();        
        for(integer count=0;count < 210; count++){
            if(count < 105)
                consultantContactId = listConsultantContact[0].Id;
            else
                consultantContactId = listConsultantContact[1].Id;
            
            listValidBlockOutDates.add(new Consultant_Block_Out_Dates__c(Consultant_Contact__c = consultantContactId,
                Not_Available_Start_Date__c = startDate.addDays(count+1),
                Not_Available_End_Date__c = endDate.addDays(count+1),
                Not_Available_Details__c = 'Test Block Out Dates - ' + (count+1)));      
        }        
        insert listValidBlockOutDates;
        
        listValidBlockOutDates = [SELECT Not_Available_Start_Date__c, Not_Available_End_Date__c FROM Consultant_Block_Out_Dates__c WHERE Id IN :listValidBlockOutDates ORDER BY Not_Available_Start_Date__c];
        
        List<Consultant_Block_Out_Dates__c> listUpdateValidBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        startDate = Date.valueOf('2016-03-02');
        endDate = Date.valueOf('2016-03-02');
        
        Test.startTest();
        for(integer count=0;count < 210; count++){
            listUpdateValidBlockOutDates.add(new Consultant_Block_Out_Dates__c(Id = listValidBlockOutDates[count].Id,
             Not_Available_Start_Date__c = startDate.addDays(count+1),
             Not_Available_End_Date__c = endDate.addDays(count+1)));      
        }
        try{
            update listUpdateValidBlockOutDates;
        }catch(DmlException e){
                        //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');            
        }
        Test.stopTest();
    }
}