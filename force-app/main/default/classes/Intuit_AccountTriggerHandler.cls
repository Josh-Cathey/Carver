public without sharing class Intuit_AccountTriggerHandler {
    public Intuit_AccountTriggerHandler() {}

    public static void updateCustomerAccounts(List<Account> newRecords, List<Account> oldRecords, Map<ID, Account> newRecordsMap, Map<ID, Account> oldRecordsMap) {
        for (Account updatedAccount : newRecords) {
            if (hasParentAccount(updatedAccount) && updatedAccount.ParentId != oldRecordsMap.get(updatedAccount.Id).ParentId && !updatedAccount.Do_Not_Sync_to_QBs__c) {
                Account parentAccount = getParentAccount(updatedAccount);
                System.debug('Intuit Account Trigger >>>> parentAcc: ' + parentAccount);

                if(!Test.isRunningTest()) {
                    if(String.isNotBlank(parentAccount.Quickbooks_ID__c)) {
                        Intuit_SyncCallout.sparseUpdateQB('Customer', (String) updatedAccount.Quickbooks_ID__c, (String) parentAccount.Quickbooks_ID__c);
                    }
                }
            }
        }
    }

    public static void createCustomerAccounts(List<Account> newAccounts) {
        for (Account newAccount : newAccounts) {
            if (hasParentAccount(newAccount) && !newAccount.Do_Not_Sync_to_QBs__c) {

            }
        }
    }

    private static Boolean hasParentAccount(Account acc) {
        return String.isNotBlank(acc.ParentId);
    }

    private static Account getParentAccount(Account acc) {
        return [SELECT Id, Quickbooks_ID__c FROM Account WHERE Id =: acc.ParentId];
    }
}
