/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    16 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
trigger Intuit_AccountTrigger on Account (before update)
{

    //may need to add additional logic for a before insert

    for(Account acc : trigger.new) {
        //if parent ID changes...
        if(((acc.parentId != Trigger.oldMap.get(acc.id).ParentId))
                && acc.parentID !=null && acc.Do_Not_Sync_to_QBs__c == false){
            Account parentAcc = [SELECT Id, Quickbooks_ID__c
                                    FROM Account
                                    WHERE Id =: acc.ParentId];
            System.debug('Intuit Account Trigger >>>> parentAcc: ' + parentAcc);

            if(!Test.isRunningTest()){
                if(parentAcc.Quickbooks_ID__c != null){
                    Intuit_SyncCallout.sparseUpdateQB('Customer', (String) acc.Quickbooks_ID__c, parentAcc.Quickbooks_ID__c);
                }
            }
        }
    }

}