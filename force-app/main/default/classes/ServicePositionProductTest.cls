/*
* Name : TestServicePositionProduct  
* Purpose : To test ServicePositionProduct trigger
* Created Date : 
*/
@isTest
public class ServicePositionProductTest  {
   
    /*  
    *    Purpose      : Create initially needed data
    */
    @TestSetup
    public static void createData()
    {
    
        //Account
        Account account = new Account();
        account.Name = 'Test';
        
        INSERT account;
        
        //Contact
        Contact contact = new Contact();
        contact.Account = account; 
        contact.LastName = 'Test contact';
        
        INSERT contact;
        
        // product
        Product2 product = new Product2();
        product.Name = 'Banquet Manager II';
        
        INSERT product;
        
          
    }
    
    /*  
    *    Purpose      : Create single record of service position
    */
    @isTest
    public static void insertSingleRecord()
    {
        Contact contactRecored = [SELECT Id, Name
                                  FROM Contact 
                                  LIMIT 1];
                                  
        Test.startTest();
        
        Service_Positions__c servicePosition = new Service_Positions__c();
        servicePosition.Name = 'Test-1';
        servicePosition.Consultant_Contact__c= contactRecored.Id;
        servicePosition.Position_Title__c = 'Banquet Manager II';
        
        Insert servicePosition;
        
        Service_Positions__c servicePositionRecord = [SELECT Id, Service_Position__c 
                                                      FROM Service_Positions__c 
                                                      LIMIT 1
                                                     ];
        servicePositionRecord.Position_Title__c = 'Catering Sales Manager II';
        
        UPDATE servicePositionRecord;
        
        Test.stopTest();
        
        Service_Positions__c updatedServicePositionRecord = [SELECT Id, Service_Position__c 
                                                      FROM Service_Positions__c 
                                                      LIMIT 1
                                                     ];
                                                     
        Product2 productRecord = [SELECT Id, Name
                                  FROM Product2 
                                  LIMIT 1
                                 ];                                           
                                                     
                                                     
        System.assertEquals(productRecord.Id, updatedServicePositionRecord.Service_Position__c); 
        
    }
    
    /*  
    *    Purpose      : Create multiple records of service position
    */
    @isTest
    public static void insertMultipleRecords()
    {
    
         // product
        Product2 product2 = new Product2();
        product2.Name = 'Catering Sales Manager II';
        
        INSERT product2;
        
        Contact contactRecored = [SELECT Id, Name
                                  FROM Contact 
                                  LIMIT 1];
           
        List<Service_Positions__c> servicePositionList = new List<Service_Positions__c>();    
                                  
        Test.startTest();
        for(Integer i=0; i<201; i++){
            Service_Positions__c servicePosition = new Service_Positions__c();
            servicePosition.Name = 'Test-1'+i;
            servicePosition.Consultant_Contact__c= contactRecored.Id;
            servicePosition.Position_Title__c = 'Banquet Manager II';
            
            servicePositionList.add(servicePosition);
        }
        Insert servicePositionList;
        
        List<Service_Positions__c> servicePositionRecords = [SELECT Id, Service_Position__c 
                                                              FROM Service_Positions__c 
                                                              LIMIT 1
                                                             ];
        
        List<Service_Positions__c> befoeUpdateServicePositionList = new List<Service_Positions__c>(); 
        
        for(Service_Positions__c servicePositionRecord : servicePositionRecords){
        
            servicePositionRecord.Position_Title__c = 'Catering Sales Manager II';
            
            befoeUpdateServicePositionList.add(servicePositionRecord);
        
        }
        UPDATE befoeUpdateServicePositionList;
        
        Test.stopTest();
        
        Service_Positions__c servicePositionRecord = [SELECT Id, Service_Position__c 
                                                      FROM Service_Positions__c 
                                                      LIMIT 1
                                                     ];
                                                     
        List<Product2> productRecords = [SELECT Id, Name
                                        FROM Product2 
                                        ORDER BY Name
                                       ];                                           
                                                     
                                                     
        System.assertEquals(productRecords[1].Id, servicePositionRecord.Service_Position__c); 
        
    }
  
}