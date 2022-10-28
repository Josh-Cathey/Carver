@isTest
private Class OpportunitySurvey2ControllerTest{

    /**
     *@purpose : To create Test data for Account, Contact. Opportunity. 
     *@param   :-
     *@return  : -              
    **/
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

    /**
     *@purpose : Test for updated opportunity. 
     *@param   :-
     *@return  : -              
    **/
    static testmethod void updateOpportunityTest() {
        //Opportunity before update.
        Opportunity opportunity = [SELECT Id, Survey2__c, Did_your_Consultant_achieve_set_goals__c, 
                                          Dressed_Professional_Manner__c, Interact_well_hotel_members_and_guests__c,
                                          Skill_set_appropriate_for_assignment__c, If_same_need_ask_for_same_consultant__c
                                   FROM Opportunity LIMIT 1];
        //Assert before update
        System.assertEquals(opportunity.Did_your_Consultant_achieve_set_goals__c, null);
        System.assertEquals(opportunity.Dressed_Professional_Manner__c, null);
        System.assertEquals(opportunity.Interact_well_hotel_members_and_guests__c, null);
        System.assertEquals(opportunity.Skill_set_appropriate_for_assignment__c, null);
        System.assertEquals(opportunity.If_same_need_ask_for_same_consultant__c, null);
        System.assertEquals(opportunity.Survey2__c, false);
        
        //pass wrong parameter to method for more code coverage.
        OpportunitySurvey2Controller.updateOpportunity(opportunity.Dressed_Professional_Manner__c, '1','2','3','4','5');

        OpportunitySurvey2Controller.updateOpportunity(opportunity.Id, '1','2','3','4','5');
        //OpportunitySurvey2Controller Instance to call getPickValues method.
        OpportunitySurvey2Controller testOpportunitySurvey2Controller = new OpportunitySurvey2Controller();
        testOpportunitySurvey2Controller.getPickValues('Opportunity', 'Did_your_Consultant_achieve_set_goals__c');

        //Opportunity after Update.
        Opportunity updatedOpportunity = [SELECT Id, Survey2__c, Did_your_Consultant_achieve_set_goals__c, 
                                                 Dressed_Professional_Manner__c, Interact_well_hotel_members_and_guests__c,
                                                 Skill_set_appropriate_for_assignment__c, If_same_need_ask_for_same_consultant__c
                                          FROM Opportunity LIMIT 1];
        //Assert after update.                                 
        System.assertEquals(updatedOpportunity.Did_your_Consultant_achieve_set_goals__c, '1');
        System.assertEquals(updatedOpportunity.Dressed_Professional_Manner__c, '2');
        System.assertEquals(updatedOpportunity.Interact_well_hotel_members_and_guests__c, '3');
        System.assertEquals(updatedOpportunity.Skill_set_appropriate_for_assignment__c, '4');
        System.assertEquals(updatedOpportunity.If_same_need_ask_for_same_consultant__c, '5');
        System.assertEquals(updatedOpportunity.Survey2__c, true);
    }
}