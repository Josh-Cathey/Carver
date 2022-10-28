/*******************************************************************************************************
    @Developer : Sagar
    @Purpose   : To test the OpportunityHelper class 
    @Created Date : 21 March 2016   
**************************************************************************************/

@isTest
private class OpportunityHelperTest {

    static testMethod void testOppHelper() {
        
        // Create Account 
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        //get standard pricebook
        Id  standardPbId = Test.getStandardPricebookId(); 

        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;

        Product2 prodcutd1 = new Product2 (Name='Test Product Entry 1',Description='Test Product Entry 1',productCode = 'ABC', isActive = true);
        insert prodcutd1;


        PricebookEntry priceBookentry = new PricebookEntry (Product2ID=prodcutd1.id,Pricebook2ID = standardPbId,UnitPrice=50, isActive=true);
        insert priceBookentry;
        
        // Create Opportunity 
        Opportunity newOpp = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(),Pricebook2Id = priceBookentry.Pricebook2Id, AccountId = acc.id);
        insert newOpp;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=newOpp.id,PriceBookEntryID=priceBookentry.id, quantity=4,totalprice=200);        
        insert lineItem1;
        
        Test.startTest();
        
        OpportunityHelper.cloneOpportunity(newOpp.Id);
        
        Integer intCount = [Select Count() From Opportunity Where Master_Opportunity__c = : newOpp.Id];
        //System.assertNotEquals(0, intCount);
        Test.stopTest();
    }
    
     static testMethod void testOppHelperNeg() {
        
        // Create Account 
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        // Create Opportunity 
        Opportunity newOpp = new Opportunity (Name='Opp1',StageName='Stage 0 - Lead Handed Off',CloseDate=Date.today(), AccountId = acc.id);
        insert newOpp;
        
        Test.startTest();
        
        OpportunityHelper.cloneOpportunity(null);
        
        Integer intCount = [Select Count() From Opportunity Where Master_Opportunity__c = : newOpp.Id];
        System.assertEquals(0, intCount);
        Test.stopTest();
    }
}