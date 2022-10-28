/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    17 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
trigger Intuit_InvoiceTrigger on QB_Activity__c (before update){
    Id invRecordtype = Schema.SObjectType.QB_Activity__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();

    for(QB_Activity__c qbActivity: trigger.new){
            if(qbActivity.RecordTypeId == invRecordtype){
                //Initially composer creates then pulls from QB and it's technically an update..
                //testing against oldmap it would be null

                if((String.isBlank(Trigger.oldMap.get(qbActivity.id).QB_Invoice_ID__c) && !String.isBlank(qbActivity.QB_Invoice_ID__c))) {
                    //double check 19 and see if this is intended
                    System.debug('Prior to qbInv trigger>>> Name of qb:' + qbActivity.Name);
                    System.debug('Prior to qbInv trigger>>> Inv Number of qb:' + qbActivity.Invoice_Number__c);

                    //Assign s-000# to Invoice Number
                    qbActivity.Invoice_Number__c = qbActivity.Name;

                    //Test callout is handled elsewhere
                    if(!Test.isRunningTest()){
                        Intuit_SyncCallout.sparseUpdateQB('Invoice', (String) qbActivity.QB_Invoice_ID__c, qbActivity.Name);
                    }
                }
            }
    }
}