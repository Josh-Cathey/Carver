@istest
class LeadPotentialRevenueRollupTest{
    
    private static Integer bulkRecordCount = 100;    
    
    static testmethod void amountsUpdateTestMethod() {
    
        List<Account> accountList = new List<Account>();
        
        Account acc1 = new Account();
        acc1.Name = 'Test Account1';
        accountList.add(acc1);
        
        Account acc2 = new Account();
        acc2.Name = 'Test Account2';
        accountList.add(acc2);
        
        insert accountList;
        
        Account accountObj;
        List<Lead> leadList = new List<Lead>();
        SFUtilityResult SFUtilityResult = SFUtilityClass.getObjectRecordTypeId('lead', 'SX - RFPs');
        Id SX_RFPsRecordTypeId;
        if(SFUtilityResult.isSuccess) {
            SX_RFPsRecordTypeId = (Id) SFUtilityResult.result[0];
        }
        
        
        // Test Bulk Insert.
        for(Integer index = 0; index < bulkRecordCount; index++) {            
            Lead leadObj = new Lead();
            leadObj.recordTypeId = SX_RFPsRecordTypeId;
            leadObj.IsConverted = false;
            leadObj.Status = 'New Bid';
            leadObj.SX_Property_Account__c = ((math.mod(index, 2) == 0) ? acc1.Id : acc2.Id);
            leadObj.LastName = 'Test' + index;
            leadObj.Company = 'Test Company' + index;            
            leadObj.LeadSource = 'Website';
            leadObj.Property_Number__c = 12;
            leadObj.Potential_Revenue__c = 100;
            leadList.add(leadObj);
        }                
        insert leadList;
        
        accountObj = [SELECT id, Lead_Potential_Revenue__c FROM Account WHERE Name = 'Test Account1'];
        System.assertEquals((bulkRecordCount/2)*100, accountObj.Lead_Potential_Revenue__c);
        
        // Test Bulk Update.
        for(Lead leadObj : leadList) {
            leadObj.Potential_Revenue__c = 200;
        }        
        update leadList;
        
        accountObj = [SELECT id, Lead_Potential_Revenue__c FROM Account WHERE Name = 'Test Account1'];
        System.assertEquals((bulkRecordCount/2)*200, accountObj.Lead_Potential_Revenue__c);
        
        // Test Bulk Delete.
        delete leadList;
        
        accountObj = [SELECT id, Lead_Potential_Revenue__c FROM Account WHERE Name = 'Test Account1'];
        System.assertEquals(0, accountObj.Lead_Potential_Revenue__c);
        
        // Test Bulk Undelete.
        undelete leadList;
        
        accountObj = [SELECT id, Lead_Potential_Revenue__c FROM Account WHERE Name = 'Test Account1'];
        System.assertEquals((bulkRecordCount/2)*200, accountObj.Lead_Potential_Revenue__c);
    }
}