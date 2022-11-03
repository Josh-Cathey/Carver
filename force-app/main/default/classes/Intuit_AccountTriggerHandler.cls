public without sharing class Intuit_AccountTriggerHandler {
    public Intuit_AccountTriggerHandler() {}

    public static void updateCustomerAccounts(List<Account> newRecords, List<Account> oldRecords, Map<ID, Account> newRecordsMap, Map<ID, Account> oldRecordsMap) {
        for(Account acc : trigger.new) {
            if(acc.ParentId != oldRecordsMap.get(acc.Id).ParentId && !String.isEmpty(acc.ParentId) && !acc.Do_Not_Sync_to_QBs__c) {
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

    public static void createCustomerAccounts(List<Account> newAccounts) {

    }
}
