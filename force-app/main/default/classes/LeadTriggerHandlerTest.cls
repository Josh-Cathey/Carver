/*
 * @Description An apex class test all the trigger functionality on Lead
 */
@isTest
private class LeadTriggerHandlerTest {
    // Used to setup data used by class
    @testSetup static void setup() {
        Lead leadObj = new Lead();
        leadObj.FirstName = 'leadFirst';
        leadObj.LastName = 'leadLast';
        leadObj.Company = 'TestComp';
        leadObj.Status = 'New';
        leadObj.LeadSource = 'Web';
        leadObj.Email = 'test@fake.com';
        try {
            insert leadObj;
            System.debug('leadObj :: ' + leadObj);
        } catch(Exception exp) { System.debug('Lead Insert Exception :: ' + exp.getMessage()); }
    }
    
    // 
    @isTest static void positiveTestLeadTriggerHandler() {
        Lead leadObj = [SELECT Id,LeadSource,Status FROM Lead LIMIT 1];
        System.assert(!leadObj.Status.equals('Qualified'));
        leadObj.Status = 'Recruiter';
        try{
            update leadObj;
        } catch(Exception exp){ System.debug('Update Lead Exception :: ' + exp.getMessage()); }
        
        leadObj = [SELECT Id,LeadSource,Status FROM Lead LIMIT 1];
        System.assert((leadObj.Status.equals('Qualified') || (leadObj.Status.equals('Converted'))));
        System.assertEquals(1,[SELECT COUNT() FROM Account]);
        System.assertEquals(1,[SELECT COUNT() FROM Contact]);
    }
    
    // 
    @isTest static void bulkTestLeadTriggerHandler() {
        List<Lead> listLeads = new List<Lead>();
        Lead leadObj;
        for(Integer index=1 ;index <= 200; index++) {
            leadObj = new Lead();
            leadObj.FirstName = 'leadFirst'+index;
            leadObj.LastName = 'leadLast'+index;
            leadObj.Company = 'TestComp' + index;
            leadObj.Status = (Math.mod(index,2) == 0) ? 'New' : 'Recruiter';
            leadObj.LeadSource = 'Web';
            leadObj.Email = 'test'+index+'@fake'+index+'.com';
            listLeads.add(leadObj);
        }
        // Start the test, this changes governor limit context to
        // that of trigger rather than test.
        test.startTest();
            try{
                insert listLeads;
                System.debug('listLeads.size :: ' + listLeads.size());
            } catch(Exception exp) { System.debug('Leads insert Exception :: ' + exp.getMessage()); }
        
        System.assertEquals(100,[SELECT COUNT() FROM Account]);
        System.assertEquals(100,[SELECT COUNT() FROM Contact]);
        // Stop the test, this changes limit context back to test from trigger.
        test.stopTest();
    }
}