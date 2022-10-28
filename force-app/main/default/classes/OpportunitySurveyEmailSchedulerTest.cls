/************************************************************************************************************************************
@purpose        : Test Class for opportunity schedular and SendOpportunitySurveyEmail batch class. 
@created date   : 21-03-2016.
**************************************************************************************************************************************/
@isTest
private Class OpportunitySurveyEmailSchedulerTest {

    /**
     *@purpose : To create Test data for Account, Contact. Opportunity. 
     *@param   :-
     *@return  : -              
    **/
    @testsetup static void createData() {
        Integer noOfRecords = 100;

        //Create Map Of RecordType name and it's Id.
        Map<String, String> recordTypeNameToIdMap = new Map<String, String>();
        for(RecordType recordTypeRec :[SELECT Id, Name 
                                       FROM RecordType 
                                       WHERE Name IN ('Consultants', 'Consultant Account', 'Task Force')]){
            recordTypeNameToIdMap.put(recordTypeRec.Name, recordTypeRec.Id);
        }
       
        Account testAccount = new Account(Name = 'TestAccount', RecordTypeId = recordTypeNameToIdMap.get('Consultant Account')); 
        INSERT testAccount;

        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i<noOfRecords; i++){
        contactList.add(new Contact(FirstName = 'Test'+i, LastName='Contact', AccountId = testAccount.Id, Email = 'test'+i+'@gmail.com', 
                                    RecordTypeId = recordTypeNameToIdMap.get('Consultants')));
        }
        INSERT contactList;
        
        List<Opportunity> testOpportunityList = new List<Opportunity>();

        for(Integer i=0; i<noOfRecords; i++){
            testOpportunityList.add(new Opportunity(Name = 'TestOpportunity'+i, CloseDate = date.today(), StageName = 'Proposal/Price Quote',
                                                    AccountId = testAccount.Id, Primary_Contact__c = contactList[i].Id, Extend__c = 'No',
                                                    Service_End_Date__c = date.today(), Service_Start_Date__c = date.today().addDays(-10),
                                                    RecordTypeId = recordTypeNameToIdMap.get('Task Force')));
        } 
                                                
        INSERT testOpportunityList;

      
    }
    @testsetup static void createEmailTemplateData() {

        List<EmailTemplate> surveyTemplateList = new List<EmailTemplate>();
        for(Integer i=1; i<3 ; i++){
            surveyTemplateList.add(new EmailTemplate(DeveloperName = 'testTemplate'+i, TemplateType = 'Custom', FolderId = UserInfo.getUserId(),
                                                     Name = 'Opportunity Survey'+ i + 'Template'));
        }

        INSERT surveyTemplateList;
     }

    /**
     *@purpose :. 
     *@param   :-
     *@return  : -              
    **/
    static testmethod void sendEmailAndUpdateOpportunityTest() {
        /*List<Opportunity> opportunityList = [SELECT id FROM Opportunity];
        System.assertEquals(90, opportunityList.size());*/

        for(Opportunity opportunityRec:[SELECT Id, Is_Survey1_Email_Send__c, Is_Survey2_Email_Send__c 
                                        FROM Opportunity]) {
            System.assertEquals(false, opportunityRec.Is_Survey1_Email_Send__c);
            System.assertEquals(false, opportunityRec.Is_Survey2_Email_Send__c);

        }
        
        Test.startTest();
        OpportunitySurveyEmailScheduler.scheduleIt();
        /*SendOpportunitySurveyEmails testSendOpportunitySurveyEmails = new SendOpportunitySurveyEmails();
        Database.executeBatch(testSendOpportunitySurveyEmails, 100);*/
        Test.stopTest();

        /*for(Opportunity updatedOpportunityRec:[SELECT Id, Is_Survey1_Email_Send__c, Is_Survey2_Email_Send__c 
                                               FROM Opportunity]) {
            System.assertEquals(true, updatedOpportunityRec.Is_Survey1_Email_Send__c);
            System.assertEquals(true, updatedOpportunityRec.Is_Survey2_Email_Send__c);
        }*/ 
    }
}