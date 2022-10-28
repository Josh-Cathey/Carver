/********************************************************************************************************************
@purpose      : UpdateTaskCountOnAccountBatch Test class
@created Date : 28 April 2017
*********************************************************************************************************************/
@isTest
private class UpdateTaskCountOnAccountBatchTest {

    Private static Integer totalNoOfRecord = 100;

    @TestSetup
    static void createTestData () {

        SFUtilityResult sfUtilityInstance;
        Id recordTypeId;

        //Account Test Data.
        sfUtilityInstance = SFUtilityClass.getObjectRecordTypeId('Account', 'SX - Property Hotels/Booking Sites');
        if(sfUtilityInstance.isSuccess) {
           recordTypeId = (Id) sfUtilityInstance.result[0];
        }

        Account accountRec = new Account(RecordTypeId = recordTypeId,
                                         Active_Property_Number__c = true,
                                         Property_Number__c = 10,
                                         Strategic_Activities_This_Period__c = 0,
                                         Reactive_Activities_This_Period__c = 0,
                                         Name = 'Test Account');
        INSERT accountRec;

        //Lead Test data.
        List<Lead> leadList =  new List<Lead>();
        sfUtilityInstance = SFUtilityClass.getObjectRecordTypeId('Lead', 'SX - Prospecting');
        if(sfUtilityInstance.isSuccess) {
           recordTypeId = (Id) sfUtilityInstance.result[0];
        }

        for(Integer i=0; i<totalNoOfRecord; i++) {

            Lead leadRec = new Lead(LastName = 'Test Lead'+i,
                                    Company = 'Test Company',
                                    Status = 'New Prospect',
                                    LeadSource = 'Other',
                                    SX_Property_Account__c = accountRec.Id,
                                    RecordTypeId = recordTypeId);

            leadList.add(leadRec);
        }

        INSERT leadList;

        //Test data for Task.
        List<Task> taskList = new List<Task>();
        for(Integer i = 0; i < totalNoOfRecord; i++) {

            Task taskRec = new Task(Subject = 'Other',
                                    Status = 'In Progress',
                                    Priority = 'Normal',
                                    ActivityDate = Date.newInstance(date.today().year(), 
                                                                    date.today().month()-1, 15),
                                    WhoId = leadList[i].Id);
            if(i<50){
                taskRec.SX_Type__c = 'Pro-Active';
            }
            else{
                taskRec.SX_Type__c = 'Reactive';
            }

            taskList.add(taskRec);
        }
        INSERT taskList;

    }

    //Test method to check count of task on account
    static testmethod void TaskCountTestOnAccount () {

        //before running batch class task count is zero.
        Account testAccount = [SELECT Id, Strategic_Activities_This_Period__c, Reactive_Activities_This_Period__c
                               FROM Account
                               LIMIT 1];

        System.assertEquals(0, testAccount.Strategic_Activities_This_Period__c);
        System.assertEquals(0, testAccount.Reactive_Activities_This_Period__c);

        Test.startTest();
            UpdateTaskCountOnAccountBatch updateTaskCount = new UpdateTaskCountOnAccountBatch();
            Database.executebatch(updateTaskCount, 1);
        Test.stopTest();

        //Task count after running the batch class.
        testAccount = [SELECT Id, Strategic_Activities_This_Period__c, Reactive_Activities_This_Period__c
                       FROM Account
                       LIMIT 1];

        System.assertEquals(50, testAccount.Strategic_Activities_This_Period__c);
        System.assertEquals(50, testAccount.Reactive_Activities_This_Period__c);
    }

 }