@isTest
public class CalendarControllerTest {
    
    @testSetup
    public static void setupTestData(){
        RecordType consultantAccount = [SELECT Id FROM RecordType WHERE Name = 'Consultant Account' AND SobjectType = 'Account'];
        Account testAccount = new Account(Name = 'Test Account',
                                          RecordTypeId = consultantAccount.Id);
        insert testAccount;
        
        RecordType consultants = [SELECT Id FROM RecordType WHERE Name = 'Consultants' AND SobjectType = 'Contact'];
        Contact testContact1 = new Contact(AccountId = testAccount.Id,
                                           LastName = 'Test Contact-1',
                                           RecordTypeId = consultants.Id);    
        insert testContact1;         
        
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
                                               Primary_Contact__c = testContact1.Id,
                                               StageName = 'Tentative',
                                               CloseDate = Date.today().addYears(1),
                                               //Consultant_Assigned__c = testContact1.Id,
                                               Service_Start_Date__c = Date.valueOf('2016-02-01'),
                                               Service_End_Date__c = Date.valueOf('2016-02-10'));
        listBookedDates.add(testOpp2);
        
        insert listBookedDates;
        
        List<Eligible_Consultant__c> eligibleConsultantList =  new List<Eligible_Consultant__c>();
        // for each opportunity
        for(Opportunity opportunit : listBookedDates){
        
            Eligible_Consultant__c EligibleConsultant = new Eligible_Consultant__c();
            EligibleConsultant.Consultant__c = testContact1.Id;
            EligibleConsultant.Opportunity__c = opportunit.Id;
            EligibleConsultant.Interested__c =  'Yes';
            EligibleConsultant.Status__c = 'Eligible'; 
            
            eligibleConsultantList.add(EligibleConsultant);
        }
        
        insert eligibleConsultantList;
        
        List<Consultant_Block_Out_Dates__c> listBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        
        Consultant_Block_Out_Dates__c testBlockOutDates1 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact1.Id,
                                                                                             Not_Available_Start_Date__c = Date.valueOf('2016-01-25'),
                                                                                             Not_Available_End_Date__c = Date.valueOf('2016-01-28'),
                                                                                             Not_Available_Details__c = 'Test Block Out Dates - 1');
        listBlockOutDates.add(testBlockOutDates1);
        
        Consultant_Block_Out_Dates__c testBlockOutDates2 = new Consultant_Block_Out_Dates__c(Consultant_Contact__c = testContact1.Id,
                                                                                             Not_Available_Start_Date__c = Date.valueOf('2016-02-25'),
                                                                                             Not_Available_End_Date__c = Date.valueOf('2016-02-28'),
                                                                                             Not_Available_Details__c = 'Test Block Out Dates - 2');
        listBlockOutDates.add(testBlockOutDates2);
        
        insert listBlockOutDates;
    }
    
    public static testmethod void testPositiveSingleRecord(){
        
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef); 
        
        Contact testContact = [SELECT Id FROM Contact
                               WHERE LastName = 'Test Contact-1'
                               LIMIT 1];
        Id consultantContactId = testContact.Id;
        
        ApexPages.standardController stdController = new ApexPages.standardController(testContact);   
        
        CalendarController controller = new CalendarController(stdController);
        
        Test.startTest();
        
        List<CalendarController.EventWrapper> listDates = CalendarController.getConsultantDates(consultantContactId);   
        System.assertEquals(4, listDates.size());
        String result = CalendarController.createConsultantBlockOutDates(consultantContactId,
                                                                         '2016-01-12',
                                                                         '2016-01-15',
                                                                         'Test Block Out Dates - 101');   
        Test.stopTest();       
        
        System.assertEquals('Block Out Dates are successfully reserved.', result);  
    }        
    
    public static testmethod void testNegativeSingleRecord(){
        
        PageReference pageRef = Page.Calendar;
        Test.setCurrentPage(pageRef); 
        
        Contact testContact = [SELECT Id FROM Contact
                               WHERE LastName = 'Test Contact-1'
                               LIMIT 1];
        Id consultantContactId = testContact.Id;
        
        ApexPages.standardController stdController = new ApexPages.standardController(testContact);   
        
        CalendarController controller = new CalendarController();
        controller = new CalendarController(stdController);
        
        Test.startTest();
        String result;
        
        CalendarController.getConsultantDates(consultantContactId);
        try{
            result = CalendarController.createConsultantBlockOutDates(consultantContactId,
                                                                      '2016-01-08',
                                                                      '2016-01-12',
                                                                      'Test Block Out Dates - 200');   
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 
                                'Consultant Not Available.' + ': []');            
        }
        System.assertEquals('Error-Consultant Not Available', result);  
        
        try{
            result= CalendarController.createConsultantBlockOutDates(consultantContactId,
                                                                     '2016-01-25',
                                                                     '2016-01-26',
                                                                     'Test Block Out Dates - 200');   
        }catch(DmlException e){
            //System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName() );
            System.assertEquals(e.getTypeName(),'System.DmlException');
            System.assertEquals(e.getMessage(),'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ' + 
                                'Block Out Dates are already blocked.' + ': []');            
        }
        System.assertEquals('Error-Block Out Dates are already blocked', result);  
        
        try{
            result= CalendarController.createConsultantBlockOutDates(null,
                                                                     '2016-01-20',
                                                                     '2016-01-22',
                                                                     'Test Block Out Dates - 200');   
        }catch(DmlException e){
            System.debug(e.getCause() + ' - ' + e.getMessage() + ' - ' + e.getTypeName());
        }
        
        Test.stopTest();       
        
        
    }        
}