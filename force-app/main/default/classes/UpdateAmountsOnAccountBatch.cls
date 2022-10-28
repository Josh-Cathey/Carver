/**
 * Trigger Handler class for handle all event after DML on Opportunity object.
 * @Created Date : 27-04-2017
 * @Authors      : Dreamwares
 */
 public class UpdateAmountsOnAccountBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    public SFUtilityResult SFUtilityResult;
    
    private static final String BASE_OBJECT = 'Opportunity';
    private static final String OPP_RECORDTYPE_NAME = 'SalesXPRESS';
    
    public void execute(SchedulableContext SC) {
        UpdateAmountsOnAccountBatch updateAmounts = new UpdateAmountsOnAccountBatch();
        Database.executebatch(updateAmounts, 200);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        SFUtilityResult = SFUtilityClass.getObjectRecordTypeId(BASE_OBJECT, OPP_RECORDTYPE_NAME);
        Id salesXPRESSRecordTypeId;
        if(SFUtilityResult.isSuccess) {
            salesXPRESSRecordTypeId = (Id) SFUtilityResult.result[0];
        }
        
        return Database.getQueryLocator([SELECT Id, Revenues_This_Period__c, Revenue_Since_Inception__c, 
                                                Closed_Pro_Active__c, Closed_Reactive__c, 
                                                (SELECT Id, Amount, CloseDate, 
                                                        StageName, SX_RFP_Account__c
                                                 FROM Opportunities1__r
                                                 WHERE RecordTypeId = :salesXPRESSRecordTypeId) 
                                         FROM Account]);
    }

    public void execute(Database.BatchableContext BC, List<Account> accountList) {
        
        List<Account> accountsToUpdate = new List<Account>();
        
        Map<String, Set<String>> taskNoToStages = new Map<String, Set<String>>{
                                        '1' => new Set<String>{'LNR', 'Courtesy Rate', 'SX Definite'},
                                        '2' => new Set<String>{'LNR', 'Courtesy Rate', 'SX Definite'},
                                        '3' => new Set<String>{'LNR', 'Courtesy Rate', 'SX Definite'},
                                        '4' => new Set<String>{'LNR', 'Courtesy Rate', 'SX Definite'}
                                    };
                                    
        Map<String, String> taskNoToFieldUpdate = new Map<String, String>{
                                        '1' => 'Revenues_This_Period__c',
                                        '2' => 'Revenue_Since_Inception__c',
                                        '3' => 'Closed_Pro_Active__c',
                                        '4' => 'Closed_Reactive__c'
                                    };
                                    
        Map<String, Double> taskNoToTotalAmount;
                                    
        Date startDateOfLastMonth = System.today().toStartOfMonth().addDays(-1).toStartOfMonth();
        Date endDateOfLastMonth = System.today().toStartOfMonth().addDays(-1);
        
        for(Account acc : accountList) {
        
            taskNoToTotalAmount = new Map<String, Double>{
                                        '1' => 0,
                                        '2' => 0,
                                        '3' => 0,
                                        '4' => 0
                                    };
                                    
            for(Opportunity opp : acc.Opportunities1__r) {
                
                Double oppAmount = ((opp.Amount != null) ? opp.Amount : 0 );
                // Task 1
                if(opp.CloseDate >= startDateOfLastMonth &&
                   opp.CloseDate <= endDateOfLastMonth &&
                   taskNoToStages.get('1').contains(opp.StageName)) {

                    taskNoToTotalAmount.put('1', taskNoToTotalAmount.get('1') + oppAmount);
                }
                // Task 2
                if(opp.CloseDate <= endDateOfLastMonth &&
                   taskNoToStages.get('2').contains(opp.StageName)) {

                    taskNoToTotalAmount.put('2', taskNoToTotalAmount.get('2') + oppAmount);
                }
                // Task 3
                if(opp.SX_RFP_Account__c == null && 
                   opp.CloseDate  <= endDateOfLastMonth &&
                   taskNoToStages.get('3').contains(opp.StageName)) {

                    taskNoToTotalAmount.put('3', taskNoToTotalAmount.get('3') + oppAmount);
                }
                // Task 4
                if(opp.SX_RFP_Account__c != null && 
                   opp.CloseDate  <= endDateOfLastMonth &&
                   taskNoToStages.get('4').contains(opp.StageName)) {
                   
                    taskNoToTotalAmount.put('4', taskNoToTotalAmount.get('4') + oppAmount);
                }
            }
            for(String taskNo : taskNoToFieldUpdate.keyset()) {
                acc.put(taskNoToFieldUpdate.get(taskNo), taskNoToTotalAmount.get(taskNo));
            }
            if(acc.Opportunities != null) {
                accountsToUpdate.add(acc);
            }
        }
        
        System.debug('accountList : ' + JSON.serialize(accountsToUpdate));
        // Update All Accounts.
        SFUtilityResult tempSFUtilityResult = SFUtilityClass.apexDMLHandler(accountsToUpdate, 'Account', SFUtilityClass.ApexDMLOption.APEX_UPDATE);
        if(!SFUtilityResult.isSuccess) {
            if(!tempSFUtilityResult.isSuccess) {
                SFUtilityResult.displayMessage += '<br/>' + tempSFUtilityResult.displayMessage;
            }
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        
        if(!SFUtilityResult.isSuccess){
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject('Error while updating Account Total Amounts');
    
            String mailBody = 'Hi '+UserInfo.getName()+'<br/>' +
                              'Error occured while running <bold>UpdateAmountsOnAccountBatch<bold><br/>'+
                              'due to : <br/>'+ SFUtilityResult.displayMessage +'<br/>'+
                              'Please contact your System Admin.';
    
            mail.setHtmlBody(mailBody);
            mail.setTargetObjectId(UserInfo.getUserId());
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}