/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    3 Nov 2022 by Josh Cathey for CP2HC-132
        - Created initial file.
*/

public without sharing class Intuit_AccountTriggerHandler {
    public Intuit_AccountTriggerHandler() {}

    public static void updateCustomerAccounts(List<Account> newRecords, List<Account> oldRecords, Map<ID, Account> newRecordsMap, Map<ID, Account> oldRecordsMap) {
        for (Account updatedAccount : newRecords) {
            // Child accounts will get a reference to the parent
            if (hasParentAccount(updatedAccount) && updatedAccount.ParentId != oldRecordsMap.get(updatedAccount.Id).ParentId && !updatedAccount.Do_Not_Sync_to_QBs__c) {
                Account parentAccount = getParentAccount(updatedAccount);
                System.debug('Intuit Account Update Trigger -> parentAccount: ' + parentAccount);

                syncAccountWithQB(updatedAccount, parentAccount);
            }
        }
    }

    public static void createCustomerAccounts(List<Account> newAccounts) {
        for (Account newAccount : newAccounts) {
            if (hasParentAccount(newAccount) && !newAccount.Do_Not_Sync_to_QBs__c) {
                Account parentAccount = getParentAccount(newAccount);
                System.debug('Intuit Account Update Trigger -> parentAccount: ' + parentAccount);

                createQBCustomer(newAccount);
                syncAccountWithQB(newAccount, parentAccount);
            }
            else if (!hasParentAccount(newAccount) && !newAccount.Do_Not_Sync_to_QBs__c) {
                // create the account
                createQBCustomer(newAccount);
            }
        }
    }

    private static Boolean hasParentAccount(Account acc) {
        return String.isNotBlank(acc.ParentId);
    }

    private static Account getParentAccount(Account acc) {
        return [SELECT Id, Quickbooks_ID__c FROM Account WHERE Id = :acc.ParentId];
    }

    private static void syncAccountWithQB(Account acc, Account parentAccount) {
        if(!Test.isRunningTest()) {
            if(String.isNotBlank(parentAccount.Quickbooks_ID__c)) {
                Intuit_SyncCallout.sparseUpdateQB('Customer', (String) acc.Quickbooks_ID__c, (String) parentAccount.Quickbooks_ID__c);
            }
            else {
                System.debug('Intuit_AccountTriggerHandler: Missing Quickbooks_ID__c on ' + acc.Id);
            }
        }
    }

    private static void createQBCustomer(Account acc) {
        if(!Test.isRunningTest()) {
            if(String.isNotBlank(acc.Quickbooks_ID__c)) {
                Intuit_SyncCallout.createCustomerQB(acc.Name);
            }
        }
    }
}
