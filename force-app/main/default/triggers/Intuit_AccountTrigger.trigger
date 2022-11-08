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

trigger Intuit_AccountTrigger on Account (before update, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            Intuit_AccountTriggerHandler.syncUpdatedCustomerAccounts(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
        }
    }
} 