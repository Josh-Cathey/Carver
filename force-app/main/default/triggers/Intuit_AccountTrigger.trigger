/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    16 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/

// Need to update for insert
trigger Intuit_AccountTrigger on Account (before update) {
    for(Account acc : trigger.new) {
        if(acc.ParentId != Trigger.oldMap.get(acc.Id).ParentId && !String.isEmpty(acc.ParentId) && !acc.Do_Not_Sync_to_QBs__c) {
            Account parentAcc = [SELECT Id, Quickbooks_ID__c
                                FROM Account
                                WHERE Id =: acc.ParentId];
            System.debug('Intuit Account Trigger >>>> parentAcc: ' + parentAcc);

            if(!Test.isRunningTest()) {
                if(!String.isEmpty(parentAcc.Quickbooks_ID__c)) {
                    Intuit_SyncCallout.sparseUpdateQB('Customer', (String) acc.Quickbooks_ID__c, (String) parentAcc.Quickbooks_ID__c);
                }
            }
        }
    }
}