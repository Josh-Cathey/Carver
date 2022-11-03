/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    16 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
    3 Nov 2022 by Josh Cathey for CP2HC-132
        - Fixing structure/style
        - Moved trigger logic to Intuit_AccountTriggerHandler.cls
        - Updated to work for insert
*/

// Need to update for insert
trigger Intuit_AccountTrigger on Account (before update, before insert) {

    if (Trigger.isBefore) {
        if(Trigger.isUpdate) {
            Intuit_AccountTriggerHandler.updateCustomerAccounts();
        }
    
        if (Trigger.isInsert) {
            Intuit_AccountTriggerHandler.createCustomerAccounts();
        }
    }

} 