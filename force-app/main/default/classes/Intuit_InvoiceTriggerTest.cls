/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    25 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@isTest
public class Intuit_InvoiceTriggerTest {
    @TestSetup
    static void setupData() {
        Account acc = new Account(Name='Test');
        insert acc;
        QB_Activity__c invoiceTest = new QB_Activity__c(Account__c = acc.Id, Total__c=12.99);
        RecordType r = [SELECT Id FROM RecordType WHERE Name='Invoice'];
        invoiceTest.RecordType = r;
        invoiceTest.Send_to_Quickbooks__c = false;

        insert invoiceTest;
    }

    @IsTest
    static void testUpdateTrigger(){
        QB_Activity__c inv = [SELECT Id, Name, Invoice_Number__c FROM QB_Activity__c WHERE Total__c = 12.99];
        inv.Total__c = 20.00;
        inv.Send_to_Quickbooks__c = true;
        inv.QB_Invoice_ID__c = '1';

        Test.startTest();
        update inv;
        Test.stopTest();
    }
}