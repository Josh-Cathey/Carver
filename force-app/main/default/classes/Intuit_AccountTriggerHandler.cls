/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    3 Nov 2022 by Josh Cathey for CP2HC-132
        - Created initial file.
*/

public without sharing class Intuit_AccountTriggerHandler {

    public static void syncUpdatedCustomerAccounts(List<Account> newRecords, List<Account> oldRecords, Map<ID, Account> newRecordsMap, Map<ID, Account> oldRecordsMap) {
        for (Account updatedAccount : newRecords) {
            if (hasParentAccount(updatedAccount) && !updatedAccount.Do_Not_Sync_to_QBs__c && String.isNotBlank(updatedAccount.Quickbooks_ID__c)) {
                Account parentAccount = getParentAccount(updatedAccount);
                System.debug('Intuit_AccountTriggerHandler -> parentAccount: ' + parentAccount);

                syncAccountHierarchyWithQB(updatedAccount, parentAccount);
            }
        }
    }

    private static Boolean hasParentAccount(Account acc) {
        return String.isNotBlank(acc.ParentId);
    }

    private static Account getParentAccount(Account acc) {
        return [SELECT Id, Quickbooks_ID__c FROM Account WHERE Id = :acc.ParentId];
    }

    private static void syncAccountHierarchyWithQB(Account acc, Account parentAccount) {
        if(!Test.isRunningTest()) {
            if(String.isNotBlank(parentAccount.Quickbooks_ID__c) && String.isNotBlank(acc.Quickbooks_ID__c)) {
                Intuit_SyncCallout.sparseUpdateQB('Customer', (String) acc.Quickbooks_ID__c, (String) parentAccount.Quickbooks_ID__c);
            }
            else {
                System.debug('Intuit_AcccountTriggerHandler: Error in syncAccountHierarchyWithQB!!!');
                System.debug('Updated Account Quickbooks_ID__c = ' + acc.Quickbooks_ID__c);
                System.debug('Parent Account Quickbooks_ID__c = ' + parentAccount.Quickbooks_ID__c);
            }
        }
    }
}