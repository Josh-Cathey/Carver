@istest
class UpdateAmountsOnAccountBatchTest{
    
    private static final String BASE_OBJECT = 'Opportunity';
    private static final String OPP_RECORDTYPE_NAME = 'SalesXPRESS';
    
    @testSetup static void setup() {
        
        Account acc = new Account();
        acc.Name = 'test Account';
        insert acc;
        
        SFUtilityResult SFUtilityResult = SFUtilityClass.getObjectRecordTypeId(BASE_OBJECT, OPP_RECORDTYPE_NAME);
        Id salesXPRESSRecordTypeId;
        if(SFUtilityResult.isSuccess) {
            salesXPRESSRecordTypeId = (Id) SFUtilityResult.result[0];
        }
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        Opportunity opp1 = new Opportunity();
        opp1.name = 'test Opp 1';
        opp1.recordTypeId = salesXPRESSRecordTypeId;
        opp1.Amount = 20;
        opp1.CloseDate = System.today().toStartOfMonth().addDays(-10); 
        opp1.StageName = 'LNR';
        opp1.AccountId = acc.Id;
        opp1.SX_RFP_Account__c = acc.Id;
        opp1.SX_Property_Account__c = acc.Id;
        oppList.add(opp1);
        
        Opportunity opp2 = new Opportunity();
        opp2.name = 'test Opp 2';
        opp2.recordTypeId = salesXPRESSRecordTypeId;
        opp2.Amount = 50;
        opp2.CloseDate = System.today().toStartOfMonth().addDays(-15); 
        opp2.StageName = 'LNR';
        opp2.AccountId = acc.Id;
        opp2.SX_RFP_Account__c = acc.Id;
        opp2.SX_Property_Account__c = acc.Id;
        oppList.add(opp2);
        
        Opportunity opp3 = new Opportunity();
        opp3.name = 'test Opp 3';
        opp3.recordTypeId = salesXPRESSRecordTypeId;
        opp3.Amount = 30;
        opp3.CloseDate = System.today().toStartOfMonth().addDays(-15); 
        opp3.StageName = 'LNR';
        opp3.AccountId = acc.Id;
        opp3.SX_Property_Account__c = acc.Id;
        oppList.add(opp3);
        
        insert oppList;
    }
    
    static testmethod void amountsUpdateTestMethod() {
        
        Test.startTest();
            UpdateAmountsOnAccountBatch updateAmounts = new UpdateAmountsOnAccountBatch();
            Database.executebatch(updateAmounts, 2);
        Test.stopTest();
        
        Account acc = [SELECT Id, Revenues_This_Period__c, Revenue_Since_Inception__c, 
                              Closed_Pro_Active__c, Closed_Reactive__c
                       FROM Account WHERE Name = 'test Account' LIMIT 1];
        
        System.assertEquals(100, acc.Revenues_This_Period__c);
        System.assertEquals(100, acc.Revenue_Since_Inception__c);
        System.assertEquals(30, acc.Closed_Pro_Active__c);
        System.assertEquals(70, acc.Closed_Reactive__c);
    }
    
    static testmethod void negativeTestCaseCoverage(){
        SFUtilityResult SFUtilityResult = SFUtilityClass.getObjectRecordTypeId('XXX', 'AAA');
        try {
            Integer i = 1/0;
        } catch(Exception exp) {
            SFUtilityClass.logMessageFromException(exp);
        }
        
        SFUtilityResult = new SFUtilityResult();
        SFUtilityResult.isSuccess = SFUtilityResult.isSuccess;
        SFUtilityResult.displayMessage = SFUtilityResult.displayMessage;
        SFUtilityResult.result = SFUtilityResult.result;
    }
}