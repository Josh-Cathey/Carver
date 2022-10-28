/**********************************************************************************************************************************
@purpose        : Test Class For OpportunitySurvey1Controller.
@created date   : 29-03-2015
***********************************************************************************************************************************/
@isTest
private Class OpportunitySurvey1ControllerTest {
    //Create Test Date of account, contact, opportunity.
    @testsetup static void createDate() {

        //Create Map Of RecordType name and it's Id.
        Map<String, String> recordTypeNameToIdMap = new Map<String, String>();
        for(RecordType recordTypeRec :[SELECT Id, Name 
                                       FROM RecordType 
                                       WHERE Name IN ('Consultants', 'Consultant Account', 'Task Force')]){
            recordTypeNameToIdMap.put(recordTypeRec.Name, recordTypeRec.Id);
        }
        
        Account testAccount = new Account(Name = 'TestAccount', RecordTypeId = recordTypeNameToIdMap.get('Consultant Account')); 
        INSERT testAccount;
        
        Contact testContact = new Contact(FirstName = 'Test', LastName='Contact', AccountId = testAccount.Id, 
                            RecordTypeId = recordTypeNameToIdMap.get('Consultants'));
        INSERT testContact;
        
        Opportunity testOpportunity = new Opportunity (Name = 'TestOpportunity', CloseDate = date.today(), 
                                                       StageName = 'Proposal/Price Quote',
                                                       AccountId = testAccount.Id, Primary_Contact__c = testContact.Id,
                                                       RecordTypeId = recordTypeNameToIdMap.get('Task Force'));
        INSERT testOpportunity;
    }

    static testmethod void updateOpportunityTest() {
        //Opportunity before update.
        Opportunity opportunity = [SELECT Id, Thumbs_Up_or_Down__c, Survey1__c FROM Opportunity LIMIT 1];
        System.assertEquals(opportunity.Thumbs_Up_or_Down__c, null);
        System.assertEquals(opportunity.Survey1__c, false);
        OpportunitySurvey1Controller.updateOpportunity(opportunity.Thumbs_Up_or_Down__c, 'Thumbs Up');
        OpportunitySurvey1Controller.updateOpportunity(opportunity.Id, 'Thumbs Up');
        //Opportunity after Update.
        Opportunity updatedOpportunity = [SELECT Id, Thumbs_Up_or_Down__c, Survey1__c FROM Opportunity LIMIT 1];
        System.assertEquals('Thumbs Up', updatedOpportunity.Thumbs_Up_or_Down__c);
        System.assertEquals(true, updatedOpportunity.Survey1__c);

     }
}