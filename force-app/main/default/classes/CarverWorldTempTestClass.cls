@isTest
public class CarverWorldTempTestClass {
    
    @testSetup static void testSetup(){
        List<OpportunityLineItem> opportunityLineItemList =new List<OpportunityLineItem>();
        // Get the Account Record type 
        Id accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consultant Account').getRecordTypeId();
        
        // Get the Contact Record type 
        Id contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consultants').getRecordTypeId();        
        Account account=new Account( RecordTypeId=accountRecordTypeId, Name=' MyTest Account' );
        
       
        INSERT account;
        
        //  Create new  contact Record
        Contact contact=new Contact(RecordTypeId=contactRecordTypeId,LastName='testClass',Account=account);
        INSERT contact;
        
        // create new opportunity Record
        Id opportunityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Carver World Temps').getRecordTypeId(); 
        
        Opportunity opportunity=new Opportunity(RecordTypeId=opportunityRecordTypeId, Name='Test opportunity' ,AccountId=account.Id,Primary_Contact__c=contact.Id,
                                                CloseDate=Date.newInstance(2016,12,31),StageName='Proposal/Price Quote'
                                               );
        INSERT opportunity;
        
        
        // Create new product Record 
        Product2 newProd = new Product2(Name = 'Housekeeping I', family = 'test family');
        INSERT newProd;      
        // Create Prize Entry For product Record
        PriceBookEntry pbEntry = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = newProd.Id,
                                                    IsActive = true
                                                   );
        INSERT pbEntry ;
        
        Product2 product = new Product2(Name = 'Maintenance', family = 'test family');
        INSERT product;      
        // Create Prize Entry For product Record
        PriceBookEntry priceBookEntry = new PriceBookEntry(UnitPrice = 100, PriceBook2Id = Test.getStandardPricebookId(),Product2Id = product.Id,
                                                           IsActive = true
                                                          );
        INSERT priceBookEntry ;
        
        
        //Create  OpportunityLineItem  Record 
        opportunityLineItemList.add(new OpportunityLineItem(OpportunityId=opportunity.Id,PricebookEntryId=pbEntry.id,TotalPrice=2000,Quantity=1
                                                           ));
        opportunityLineItemList.add(new OpportunityLineItem(OpportunityId=opportunity.Id,PricebookEntryId=priceBookEntry.id,TotalPrice=300,Quantity=2
                                                           ));
        INSERT opportunityLineItemList;
          
    }
    
    // test Method For inserting single Record Carver_World_Temps__c  
    static testMethod void testSingleRecord(){
        
        Opportunity opportunity=new Opportunity();
        
        //  get the opportunity record 
        Opportunity=[SELECT id,Name FROM  Opportunity WHERE Name='Test opportunity' LIMIT 1];     
        
        //  Create new Carver_World_Temps__c Record in opportunity
        Carver_World_Temps__c carverWorldTempsObj=new Carver_World_Temps__c(CWT_Opportunity__c=Opportunity.Id,Default_Jobs__c='Housekeeping I');
        
        System.assertEquals(Opportunity.Id,carverWorldTempsObj.CWT_Opportunity__c );
        Test.startTest();
        INSERT carverWorldTempsObj;
        Test.stopTest();
        Carver_World_Temps__c testCarverWorldTemps=[SELECT Bill_Rate__c FROM Carver_World_Temps__c WHERE CWT_Opportunity__c=:Opportunity.Id];
        System.assertEquals(2000, testCarverWorldTemps.Bill_Rate__c);
        
    }
    
    static testMethod void testBulkRecord(){
        
        Opportunity opportunity=new Opportunity();
        
        //  get the opportunity record 
        Opportunity=[SELECT id,Name FROM  Opportunity WHERE Name='Test opportunity' LIMIT 1];     
        
        //  Create new Carver_World_Temps__c Record in opportunity
        Carver_World_Temps__c carverWorldTempsObj=new Carver_World_Temps__c();
        List<Carver_World_Temps__c> listCarverWorldTemps=new List<Carver_World_Temps__c>();
        For(Integer iteratore=0;iteratore<210;iteratore++){
            listCarverWorldTemps.add(new Carver_World_Temps__c(CWT_Opportunity__c=Opportunity.Id,Default_Jobs__c='Housekeeping I'));
            if(iteratore>105)
                listCarverWorldTemps.add(new Carver_World_Temps__c(CWT_Opportunity__c=Opportunity.Id,Default_Jobs__c='Maintenance'));
        }
        
        //System.assertEquals(Opportunity.Id,carverWorldTempsObj.CWT_Opportunity__c );
        Test.startTest();
        INSERT listCarverWorldTemps;
        Test.stopTest();
        
        listCarverWorldTemps = [SELECT Bill_Rate__c,Default_Jobs__c FROM Carver_World_Temps__c];
        for (Carver_World_Temps__c testCarverWorldTemp: listCarverWorldTemps) {
            if(testCarverWorldTemp.Default_Jobs__c=='Housekeeping I')
                System.assertEquals(2000, testCarverWorldTemp.Bill_Rate__c);
            if(testCarverWorldTemp.Default_Jobs__c=='Maintenance')
                System.assertEquals(150, testCarverWorldTemp.Bill_Rate__c);
        }
        
        
        //  Carver_World_Temps__c testCarverWorldTemps=[SELECT Bill_Rate__c FROM Carver_World_Temps__c WHERE Default_Jobs__c='Housekeeping I'];
        System.assertEquals(210, [SELECT COUNT() FROM Carver_World_Temps__c WHERE Default_Jobs__c='Housekeeping I']);
        
        //   testCarverWorldTemps=[SELECT Bill_Rate__c FROM Carver_World_Temps__c WHERE Default_Jobs__c='Maintenance'];
        System.assertEquals(104, [SELECT COUNT() FROM Carver_World_Temps__c WHERE Default_Jobs__c='Maintenance']);
       
               
    }
    
}