/**
 *@Class Name   : TargetListControllerTest
 *@Purpose      : Test class for TargetListController
 *@Created Date : 28-02-2018
 *@Modified Date: 
 */

@isTest
private class TargetListControllerTest {
   /**
     *@purpose   : create test data.
     *@parameter : - 
     *@return    : -
     */
    @testSetup
    private static void insertTestData(){ 
        //Creating Account Record
        Account accountRecord = createAccount();
        
        //Creating Opportynity Record
        Opportunity opportunityRecord = createOpportunity(accountRecord);
        opportunityRecord = [ SELECT Id, Family_of_Brands__c, RecordTypeId, 
                             	     AccountId,Name,Pricebook2Id,StageName,Family_of_Hotel_Brands__c,State__c,
                             	     of_Rooms__c,CloseDate,Salary_High_Range__c,Salary_Low_Range__c,
                                     Salary_High_Range_Factor__c,Salary_Low_Range_Factor__c
                              FROM Opportunity 
                              WHERE Id =: opportunityRecord.Id ];
        
        //Creating Product2 reords
        List<Product2> productList = createProducts();
        
        //Creating Price book entries records
        createPricebookEntries(productList);
        
        //Creating Opportunity Line item records
        createOpportunityLineItems(opportunityRecord,productList);
        
        //Creating Contact record
        List<Contact> contactList = createContacts(accountRecord);
        
        //Creating Job_Experience record
        createJobExperience(contactList);
        
        //Creating Consultant record
        List<Consultant__c> ConsultantList = createConsultants();
        
        //Creating Brands records
        createBrands(opportunityRecord,ConsultantList,contactList);
        
        //Creating Service Positions records
        createServicePositions(productList,ConsultantList,contactList);
    }
    
    /**
     *@purpose   : get Record Type Id
     *@parameter : sObjectType,recordTypeName 
     *@return    : RecordTypeID
     */
    public static String getObjectRecordTypeId(SObjectType sObjectType, String recordTypeName)
    {
        if(!sObjectType.getDescribe().getRecordTypeInfosByName().containsKey(recordTypeName))
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');

        //Retrieve the record type id by name
        return sObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
    }
    
    /**
     *@purpose   : create Account record
     *@parameter : - 
     *@return    : Account record
     */
    private static Account createAccount(){
        //getting RecordType Id
        Id recordTypeId = getObjectRecordTypeId(Account.SObjectType,'Partners');
      
        // Creating new account record
        Account accountRecord = new Account(Name = 'TestAccount1',
                                            RecordTypeId = recordTypeId,
                                            Family_Brand__c ='Best Western'
                                           ); 
        //Inserting account
        insert accountRecord ;
        return accountRecord;
    }
    
    /**
     *@purpose   : create Opportunity records
     *@parameter : accountRecord 
     *@return    : opportunity Record
     */
    private static Opportunity createOpportunity(Account accountRecord){
        //getting RecordType Id
        Id recordTypeId = getObjectRecordTypeId(Opportunity.SObjectType,'Search');
        
        //getting standard price book ID
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create Opportunity record
       
        Opportunity opportunityRecord = new Opportunity( RecordTypeId = recordTypeId,
                                                          AccountId = accountRecord.Id,
                                                          Name = 'testOpportunity',
                                                          Pricebook2Id = pricebookId,
                                                          StageName = 'Creating Target List',
                                                          Family_of_Hotel_Brands__c = 'Best Western',
                                                          State__c = 'AK',
                                                          of_Rooms__c = 30,
                                                          Salary_High_Range__c = 10000,
                                                          Salary_Low_Range__c = 1000,
                                                          CloseDate = System.today()
                                                         );
        //Inserting opportunity
        insert opportunityRecord;             
        return opportunityRecord;
    }
    
    /**
     *@purpose   : create Product records
     *@parameter : - 
     *@return    : productList
     */
    private static List<Product2> createProducts(){
        //Create Product Records
        List<Product2> productList = new List<Product2>();
        for(Integer productRecordIndex = 0; productRecordIndex < 10 ; productRecordIndex++){
            productList.add(new Product2( Name = 'Product'+productRecordIndex
                						));
                         
        }
        //Inserting Product list
        insert productList;
        return productList;
    }
     
    /**
     *@purpose   : create PricebookEntry records
     *@parameter : productList
     *@return    : priceBookEntriesList
     */
    private static void createPricebookEntries( List<Product2> productList){
        //getting standard price book ID
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create PricebookEntriy Records
        List<PricebookEntry> priceBookEntriesList = new  List<PricebookEntry>();
        for(Integer priceBookEntryRecordIndex = 0; priceBookEntryRecordIndex < 10 ; priceBookEntryRecordIndex ++){
            priceBookEntriesList.add(new PricebookEntry( Product2Id = productList[priceBookEntryRecordIndex].id,
                                                         Pricebook2Id = pricebookId,
                                                         UseStandardPrice = false,
                                                         UnitPrice = 500,
                                                         IsActive = true));
                                                        
        }
        //Inserting PricebookEntry list
        insert priceBookEntriesList;
    }
    
    /**
     *@purpose   : create Opportunity Line Items records
     *@parameter : opportunityRecord,productList 
     *@return    : opportunityLineItemsList
     */
    private static List<OpportunityLineItem> createOpportunityLineItems(Opportunity opportunityRecord,
                                                                     List<Product2> productList){
        List<OpportunityLineItem> opportunityLineItemsList = new List<OpportunityLineItem>();
        for(Integer opptyLineItemRecord = 0; opptyLineItemRecord < 10; opptyLineItemRecord++){
             opportunityLineItemsList.add(new OpportunityLineItem(UnitPrice = 1000,
                                                                  Quantity =2,
                                                                  Product2Id = productList[0].Id,
                                                                  OpportunityId = opportunityRecord.Id
                                                                  ));
        }
        //Inserting opportunityLineItemsList
        insert opportunityLineItemsList;
        return opportunityLineItemsList;
    }
    
    /**
     *@purpose   : get Contact record
     *@parameter : accountRecord
     *@return    : contact
     */
    private static List<Contact> createContacts(Account accountRecord){
        //getting RecordType Id
        Id recordTypeId = getObjectRecordTypeId(Contact.SObjectType,'Consultants');
        
        List<Contact> contactList = new List<Contact>();
        
        Contact ContactRecord1 = new Contact(RecordTypeId = recordTypeId,
                                            FirstName = 'French',
                                            LastName = 'Disuza',
                                            Phone = '89786785645',
                                            Email ='testContact@gmail.com',
                                            AccountId = accountRecord.Id,
                                            Current_Salary__c = 5000,
                                            MailingCity = 'test city',
                                            MailingState = 'US',
                                            Will_Relocate__c = true,
                                            US_Citizen__c = true,
                                            Union_Experience__c = true,
                                            Permanent_Placement__c = true,
                                            State__c = 'AK',
                                            Recruiting_Source__c = 'LinkedIn',
                                            Years_of_Experience__c = 20,
                                            Currently_Employed__c = true,
                                            Current_Position_Title__c ='Manager',
                                            Consultant_Status__c = 'Active');
        
        Contact ContactRecord2 = new Contact(RecordTypeId = recordTypeId,
                                            FirstName = 'French',
                                            LastName = 'Disuza',
                                            Phone = '89786785645',
                                            Email ='testContact@gmail.com',
                                            AccountId = accountRecord.Id,
                                            Current_Salary__c = 5000,
                                            MailingCity = 'test city',
                                            MailingState = 'US',
                                            Will_Relocate__c = true,
                                            US_Citizen__c = true,
                                            Union_Experience__c = true,
                                            Permanent_Placement__c = true,
                                            State__c = 'CO',
                                            Recruiting_Source__c = 'LinkedIn',
                                            Years_of_Experience__c = 20,
                                            Currently_Employed__c = true,
                                            Current_Position_Title__c ='Manager',
                                            Consultant_Status__c = 'Active');
       
        contactList.add(ContactRecord1);
        contactList.add(ContactRecord2);
        
        for(Integer contactRec = 0; contactRec < 50 ; contactRec++){
            contactList.add(new Contact(RecordTypeId = recordTypeId,
                                        FirstName = 'French'+contactRec,
                                        LastName = 'Disuza'+contactRec,
                                        Phone = '89786785645',
                                        Email ='testContact'+contactRec+'@gmail.com',
                                        AccountId = accountRecord.Id,
                                        Current_Salary__c = 11000,
                                        MailingCity = 'test city',
                                        MailingState = 'KS',
                                        Will_Relocate__c = true,
                                        US_Citizen__c = true,
                                        Union_Experience__c = true,
                                        Permanent_Placement__c = true,
                                        State__c = '',
                                        Recruiting_Source__c = 'LinkedIn',
                                        Years_of_Experience__c = 20,
                                       	Currently_Employed__c = true,
                                       	Current_Position_Title__c ='Manager',
                                        Consultant_Status__c = 'Active'));
        }
        
        for(Integer contactRec = 0; contactRec < 50 ; contactRec++){
            contactList.add(new Contact(RecordTypeId = recordTypeId,
                                        FirstName = 'French'+contactRec,
                                        LastName = 'Disuza'+contactRec,
                                        Phone = '89786785645',
                                        Email ='testContact'+contactRec+'@gmail.com',
                                        AccountId = accountRecord.Id,
                                        Current_Salary__c = 11000,
                                        MailingCity = 'test city',
                                        MailingState = 'KS',
                                        Will_Relocate__c = true,
                                        US_Citizen__c = true,
                                        Union_Experience__c = true,
                                        Permanent_Placement__c = true,
                                        State__c = 'AK',
                                        Recruiting_Source__c = 'LinkedIn',
                                        Years_of_Experience__c = 20,
                                       	Currently_Employed__c = true,
                                       	Current_Position_Title__c ='Manager',
                                       Consultant_Status__c = 'Active'));
        }
        //Inserting ContactList
        insert contactList;
        return contactList;
    }
    
    /**
     *@purpose   : create Consultant records
     *@parameter :  -
     *@return    : ConsultantList
     */
    private static List<Consultant__c> createConsultants(){
        List<Consultant__c> ConsultantList = new  List<Consultant__c>();
        for(Integer consultantRecord = 0; consultantRecord<10 ;consultantRecord++){
           ConsultantList.add(new Consultant__c(Name ='test con')); 
        }
        //Inserting ConsultantList
        insert ConsultantList;
        return ConsultantList;
    }
    
    /**
     *@purpose   : create Job_Experience__c records
     *@parameter : contactList
     *@return    : Job_Experience__c list
     */
    private static void createJobExperience(List<Contact> contactList){
        List<Job_Experience__c> jobExperienceList = new List<Job_Experience__c>();
        for(Contact contactRecord :contactList){
            jobExperienceList.add(new Job_Experience__c(of_Rooms__c = 50,
                                                       Consultant__c = contactRecord.Id));
            
            jobExperienceList.add(new Job_Experience__c(of_Rooms__c = 20,
                                                       Consultant__c = contactRecord.Id));   
        }
        insert jobExperienceList;
    }
    
    /**
     *@purpose   : get Brands records
     *@parameter : opportunityRecord,consultantList,contactList
     *@return    : brandList
     */
    private static List<Brands__c> createBrands(Opportunity opportunityRecord,List<Consultant__c> consultantList,
                                             List<Contact> contactList){
        List<Brands__c> brandList = new List<Brands__c>();
        for(Contact contactRecord :contactList){
           
            brandList.add(new Brands__c(Family_of_Brands__c = opportunityRecord.Family_of_Brands__c,
                                        Consultant__c = consultantList[0].Id,
                                        Consultant_Contact__c = contactRecord.Id)); 
            brandList.add(new Brands__c(Family_of_Brands__c = opportunityRecord.Family_of_Brands__c,
                                        Consultant__c = consultantList[0].Id,
                                        Consultant_Contact__c = contactRecord.Id));
        }
        //Inserting brandLis
        insert brandList;
        return brandList;
    } 
    
    /**
     *@purpose   : create servicePositions records
     *@parameter : productList,consultantList,contactRecord
     *@return    : servicePositionsList
     */
    private static List<Service_Positions__c> createServicePositions( List<Product2> productList,
                                                                   List<Consultant__c> consultantList,
                                                                   List<Contact> contactList){
        List<Service_Positions__c> servicePositionsList = new List<Service_Positions__c>();
        for(Contact contactRecord :contactList){
            servicePositionsList.add(new Service_Positions__c(Service_Position__c = productList[0].Id,
                                                              Consultant__c = consultantList[0].Id,
                                                              Consultant_Contact__c = contactRecord.Id));
            servicePositionsList.add(new Service_Positions__c(Service_Position__c = productList[0].Id,
                                                              Consultant__c = consultantList[0].Id,
                                                              Consultant_Contact__c = contactRecord.Id));
        }
        //Inserting brandLis
        insert servicePositionsList;
        return servicePositionsList;
    } 
    
    /**
     *@purpose   : get TargetListWrapperList
     *@parameter : contactList
     *@return    : TargetListWrapperList
     */
    private static List<TargetListWrapper.contactDTO> getTargetListWrapperList(List<Contact> contactList){
        List<TargetListWrapper.contactDTO> targetListWrapperList = new List<TargetListWrapper.contactDTO>();
        for(Contact contactRec : contactList){
            targetListWrapperList.add(new TargetListWrapper.contactDTO(contactRec, true));
        }
        return targetListWrapperList;
    }
    
    /**
     *@purpose   : get Opportunity record string
     *@parameter : Opportunity
     *@return    : OpportunityRecordString
     */
    private static String getOppRecordString(Opportunity opportunityRecord){
        TargetListWrapper.OpportunityDTO opportunityDTO = new TargetListWrapper.OpportunityDTO();
        opportunityDTO.recordId = opportunityRecord.id;
        opportunityDTO.familyOfHotelBrand = opportunityRecord.Family_of_Hotel_Brands__c;
        opportunityDTO.state = opportunityRecord.State__c;
        opportunityDTO.noOfRoom = (Integer)opportunityRecord.of_Rooms__c;
        opportunityDTO.salaryLowRangeFactor = String.valueOf(opportunityRecord.Salary_Low_Range_Factor__c);
        opportunityDTO.salaryHighRangeFactor = String.valueOf(opportunityRecord.Salary_High_Range_Factor__c);
        
        return serializeObject(opportunityDTO);  
    }
  
    /**
     *@purpose   : get Opportunity Line Items String
     *@parameter : -
     *@return    : -
     */
    private static String getOppLineItemStr(){
       String oppLineItemString;
       List<OpportunityLineItem> opportunityLineItemsList = [SELECT Id
                                                             FROM OpportunityLineItem];
        for(OpportunityLineItem oppLineItem :opportunityLineItemsList){
            oppLineItemString = oppLineItem.Id + ',';
        }
        return oppLineItemString.removeEnd(',');
        
    }
    /**
     *@purpose   : get Account Record String
     *@parameter : 
     *@return    : 
     */
    private static String getAccountString(){
        TargetListController.accountDTO accountDTO= new TargetListController.accountDTO();
        accountDTO.firstName = 'Albert';
        accountDTO.lastName = 'Disuza';
        
        return serializeObject(accountDTO);
    }
    
    /**
     *@purpose   : get Contact Record String
     *@parameter : contactRecord
     *@return    : -
     */
    private static String getContactString(Contact contactRecord){
        TargetListController.contactDTO contactDTO= new TargetListController.contactDTO();
        contactDTO.firstName = contactRecord.FirstName;
        contactDTO.lastName = contactRecord.LastName;
        contactDTO.currentPositionTitle = contactRecord.Current_Position_Title__c;
        contactDTO.Email = contactRecord.Email;
        contactDTO.Phone = contactRecord.Phone;
        contactDTO.city = contactRecord.MailingCity;
        contactDTO.state = contactRecord.MailingState;
        contactDTO.yearsOfExperience = String.valueOf(contactRecord.Years_of_Experience__c);
        contactDTO.currentlyEmployed = contactRecord.Currently_Employed__c;
        contactDTO.currentSalary = String.valueOf(contactRecord.Current_Salary__c);
        contactDTO.recruitingSource = contactRecord.Recruiting_Source__c;
        
        return serializeObject(contactDTO);
    }
    
    /**
     *@purpose   : get Serialize String
     *@parameter : Object
     *@return    : Serialized String
     */
    private static String serializeObject(Object obj){
        return JSON.serialize(obj);
    }
    
    /*
     *@purpose : Positively test TargetListController class methods 
     */
    private static testMethod void TargetListConPositiveTest(){
        //Start test
        test.startTest();
        
        //Fetch Account Record
        Account accountRecord = [SELECT Id,Name,Family_Brand__c 
                                 FROM Account 
                                 LIMIT 1];
        //Fetch Opportunity records
        Opportunity opportunityRecord =[SELECT Id,Name,StageName,Family_of_Hotel_Brands__c,State__c,of_Rooms__c,
                                                Family_of_Brands__c,Salary_Low_Range__c,Salary_High_Range_Factor__c,
                                                Salary_Low_Range_Factor__c,Salary_High_Range__c
                                         FROM Opportunity 
                                         LIMIT 1];
        
        //Fetch Contact records
        List<Contact> contactList = [SELECT Id,Name,FirstName,LastName,of_Rooms__c,US_Citizen__c,
                                             Current_Salary__c,Recruiting_Source__c,MailingCity,MailingState,Will_Relocate__c,
                                             Union_Experience__c,Currently_Employed__c,
                                             Years_of_Experience__c,Current_Position_Title__c,Phone,Email,
                                      (SELECT Id,Family_of_Brands__c FROM Brands__r),
                                      (SELECT Id,Service_Position__c FROM Service_Position__r) 
                                      FROM Contact];
              
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdOpportunity = new ApexPages.StandardController(opportunityRecord); 
        TargetListController targetListCon = new TargetListController(stdOpportunity);
        targetListCon.opp = opportunityRecord;
        
        String oppRecordStr = getOppRecordString(opportunityRecord);
        List<TargetListWrapper.contactDTO> targetListWrapperList = getTargetListWrapperList(contactList);
        String accountString = getAccountString();
        String contactSting = getContactString(contactList[0]);
        
        TargetListController.Response response;   
        response = TargetListController.getContactRecords(oppRecordStr,
                                                          getOppLineItemStr(),
                                                          '{"StateFilter":false,"familyOfBrandsFilters":true,"noOfRoomsFilter":true,"desiredSalary":false}');
        //checking Created Contacts size
        //System.assertEquals(51,response.recordList.size());
        
        response = TargetListController.getContactRecords(oppRecordStr,
                                                          getOppLineItemStr(),
                                                          '{"StateFilter":true,"familyOfBrandsFilters":false,"noOfRoomsFilter":true,"desiredSalary":true}');
        //checking Created Contacts size
        System.assertEquals(102,response.recordList.size());
        
        response = TargetListController.getContactRecords(oppRecordStr,
                                                          getOppLineItemStr(),
                                                          '{"StateFilter":false,"familyOfBrandsFilters":false,"noOfRoomsFilter":false,"desiredSalary":false}');
        //checking Created Contacts size
        //System.assertEquals(51,response.recordList.size());
        
        response = TargetListController.createTargetList(oppRecordStr,targetListWrapperList);
        //checking Created targetList size
        //System.assertEquals(102,response.recordList.size());
        
        response = TargetListController.createAccountRecord(accountString);
        System.assertEquals(true,response.isSuccess);
     
        response = TargetListController.createContactRecord(contactSting,accountRecord);
        System.assertEquals(true,response.isSuccess);
       
        response = TargetListController.createTargetListRecord(contactList[0].Id,opportunityRecord.Id);
        System.assertEquals(true,response.isSuccess);
   
        TargetListController.getPickListValuesIntoList();
        
        //Stop test
        test.stopTest();
    }
    
    /*
     *@purpose : Negatively test TargetListController class methods 
     */ 
    private static testMethod void TargetListConNegativeTest(){
        //Start test
        test.startTest();
        
        //getting RecordType Id
        Id recordTypeId = getObjectRecordTypeId(Opportunity.SObjectType,'Carver World Temps');
        
        //Fetch Account Record
        Account accountRecord = [SELECT Id,Name,Family_Brand__c 
                                 FROM Account 
                                 LIMIT 1];
        
        //Fetch Opportunity records
        Opportunity opportunityRecord = [SELECT Id,Name,AccountId,StageName,Family_of_Hotel_Brands__c,State__c,of_Rooms__c
                                          FROM Opportunity LIMIT 1];
        opportunityRecord.RecordTypeId = recordTypeId ;
        opportunityRecord.State__c = null;
        opportunityRecord.of_Rooms__c = 0;
        opportunityRecord.AccountId = accountRecord.Id;
        
        //Update Opportunity Record
        update opportunityRecord;
        
        //Fetch Contacts List
        List<Contact> contactList = [SELECT Id,Name,FirstName,LastName,of_Rooms__c,US_Citizen__c,
                                             Current_Salary__c,Recruiting_Source__c,MailingCity,MailingState,Will_Relocate__c,
                                             Union_Experience__c,Currently_Employed__c,Years_of_Experience__c,
                                             Current_Position_Title__c,Phone,Email,
                                     (SELECT Id,Family_of_Brands__c FROM Brands__r),
                                     (SELECT Id,Service_Position__c FROM Service_Position__r) 
                                     FROM Contact];
        
        //Create ApexPages.StandardController instance 
        ApexPages.StandardController stdOpportunity = new ApexPages.StandardController(opportunityRecord); 
        TargetListController targetListCon = new TargetListController(stdOpportunity);
        
        String oppRecordStr = getOppRecordString(opportunityRecord);
        List<TargetListWrapper.contactDTO> targetListWrapperList = getTargetListWrapperList(contactList);
        String accountString = getAccountString();
        String contactSting = getContactString(contactList[0]);
        
        TargetListController.Response response;   
        response = TargetListController.getContactRecords(oppRecordStr,
                                                          getOppLineItemStr(),
                                                          null);
        //checking Created Contacts size
        System.assertEquals(false,response.isSuccess);
        
        response = TargetListController.createTargetList(null,targetListWrapperList);
        //checking Created targetList size
        System.assertEquals(false,response.isSuccess);
        
        response = TargetListController.createAccountRecord(null);
        System.assertEquals(false,response.isSuccess);
        
        response = TargetListController.createContactRecord(contactSting,null);
        System.assertEquals(false,response.isSuccess);
      
        response = TargetListController.createTargetListRecord(contactList[0].id,null);
        System.assertEquals(false,response.isSuccess);
        
        TargetListController.getPickListValuesIntoList();
        
        //Stop test
        test.stopTest();
    }
    
    public class RecordTypeException extends Exception{}
}