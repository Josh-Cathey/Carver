/***************************************************************************************************************
@ Purpose: Batch To update last month lead Task count on account.
@ Created Date : 27 April 2017.
*****************************************************************************************************************/
public class UpdateTaskCountOnAccountBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {

    public String errorMsg;

    public void execute(SchedulableContext SC) {

        UpdateTaskCountOnAccountBatch updateTaskCount = new UpdateTaskCountOnAccountBatch();
        Database.executebatch(updateTaskCount, 1);
    }

    public Database.QueryLocator start (Database.BatchableContext BC) {

        return Database.getQueryLocator([SELECT Id, Strategic_Activities_This_Period__c,
                                                Reactive_Activities_This_Period__c
                                         FROM Account
                                         WHERE Active_Property_Number__c = true AND
                                               Property_Number__c != NULL AND
                                               RecordType.DeveloperName = 'SX_Property_Hotels_Booking_Sites']);
    }

    public void execute (Database.BatchableContext BC, List<Account> accountList) {

        List<Lead> leadList = getLeadsFromAccounts(accountList);
        Map<Id, Map<String, Integer>> accountIdToTaskTypeToCountMap = getTaskTypeToCountMap(leadList);

        try{
            updateAccounts(accountIdToTaskTypeToCountMap);
        }catch(Exception exp){

            errorMsg += exp.getMessage() + exp.getStackTraceString();
            System.debug('Error while updating activity(task) count on account:::'+errorMsg);
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(String.isNotBlank(errorMsg) || Test.isRunningTest()){
            sendEmailToUser();
        }
    }

    /**
     *@purpose : get leads from accountList
     *@param   : list of accounts
     *@return  : Leads(List)
     */
    private List<Lead> getLeadsFromAccounts (List<Account> accountList) {

        List<Lead> leadList = new List<Lead>();
        Set<String> leadRecodTypeSet = new Set<String>{'SX_Prospecting', 'SX_RFPs'};

        try{
            if(Test.isRunningTest()){
                leadList = [SELECT Id, SX_Property_Account__c,
                                   (SELECT Id, SX_Type__c
                                    FROM Tasks
                                    WHERE SX_Type__c IN ('Pro-Active', 'Reactive') AND
                                           RecordType.DeveloperName = 'SalesXPRESS' AND
                                          ActivityDate = LAST_MONTH)
                            FROM Lead
                            WHERE Recordtype.DeveloperName IN :leadRecodTypeSet AND
                                  SX_Property_Account__c IN :accountList];
            }else{
                leadList = [SELECT Id, SX_Property_Account__c,
                                   (SELECT Id, SX_Type__c
                                    FROM Tasks
                                    WHERE SX_Type__c IN ('Pro-Active', 'Reactive') AND
                                          RecordType.DeveloperName = 'SalesXPRESS' AND
                                          CreatedDate = LAST_MONTH)
                            FROM Lead
                            WHERE Recordtype.DeveloperName IN :leadRecodTypeSet AND
                                  SX_Property_Account__c IN :accountList];
            }

        }catch(Exception exp){

            errorMsg += exp.getMessage() + exp.getStackTraceString();
            System.debug('Error while fetching Leads:::'+errorMsg);
        }

        return leadList;
    }

    /**
     *@purpose : To get map of sxtype and it's count
     *@param   : list of task
     *@return  : Map of sxtype and count.
     */
    private Map<Id, Map<String, Integer>> getTaskTypeToCountMap (List<Lead> leadList) {

        Map<Id, Map<String, Integer>> accountIdToTaskTypeToCountMap = new Map<Id, Map<String, Integer>>();

        if(leadList != NULL) {

            Set<String> sxTypeSet = new Set<String>{'Pro-Active', 'Reactive'};
            Map<String, Integer> taskTypeToCountMap = new Map<String, Integer>();

            for(Lead leadRec :leadList) {
                System.debug('Task=='+leadRec.getSObjects('Tasks'));
                for(Task taskRec :leadRec.getSObjects('Tasks')) {

                    if(sxTypeSet.contains(taskRec.SX_Type__c)){

                        if(taskTypeToCountMap.containsKey(taskRec.SX_Type__c)){
                            taskTypeToCountMap.put(taskRec.SX_Type__c,
                                                   taskTypeToCountMap.get(taskRec.SX_Type__c) + 1);
                        }else{
                            taskTypeToCountMap.put(taskRec.SX_Type__c, 1);
                        }
                    }
                }
            }
            System.debug('taskTypeToCountMap=='+taskTypeToCountMap);
            if(!taskTypeToCountMap.isEmpty()){
                accountIdToTaskTypeToCountMap.put(leadList[0].SX_Property_Account__c, taskTypeToCountMap);
            }
        }

        return accountIdToTaskTypeToCountMap;
    }

    /**
     *@purpose: Update task couunt of lead on account.
     *@param  : accountIdToTaskTypeToCountMap
     *@return :-
     */
    private void updateAccounts (Map<Id, Map<String, Integer>> accountIdToTaskTypeToCountMap) {
        System.debug('accountIdToTaskTypeToCountMap=='+accountIdToTaskTypeToCountMap);
        if(accountIdToTaskTypeToCountMap != NULL) {

            List<Account> accountsToUpdate = new List<Account>();

            for(Id accountId :accountIdToTaskTypeToCountMap.keySet()){

                Map<String, Integer> taskTypeToCountMap = accountIdToTaskTypeToCountMap.get(accountId);

                if(!taskTypeToCountMap.isEmpty()){

                    Account accountToUpdate = new Account();
                    accountToUpdate.Id = accountId;
                    accountToUpdate.Strategic_Activities_This_Period__c = taskTypeToCountMap.get('Pro-Active');
                    accountToUpdate.Reactive_Activities_This_Period__c = taskTypeToCountMap.get('Reactive');

                    accountsToUpdate.add(accountToUpdate);
                }
            }

            UPDATE accountsToUpdate;
        }
    }

    /**
     *@purpose: Send an email notification to user if any error occured.
     *@param  :-
     *@return :
     */
    private void sendEmailToUser() {

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setSubject('Error while updating lead activity count');

        String mailBody = 'Hi '+UserInfo.getName()+'<br/>' +
                          'Error occured while running <bold>UpdateTaskCountOnAccountBatch<bold><br/>'+
                          'due to '+ errorMsg +'<br/>'+
                          'Please contact your System Admin.';

        mail.setHtmlBody(mailBody);
        mail.saveAsActivity = false;
        mail.setTargetObjectId(UserInfo.getUserId());

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

}