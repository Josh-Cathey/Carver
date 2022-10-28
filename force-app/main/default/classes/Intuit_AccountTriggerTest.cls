/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    25 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_AccountTriggerTest {

    @TestSetup
    static void setupData(){
        Account parentAcc = new Account(Name='testParent', Quickbooks_ID__c = '1');
        insert parentAcc;

        Account childAcc1 = new Account(Name='child1', ParentId = parentAcc.Id, Quickbooks_ID__c = '2');
        insert childAcc1;

        Account childAcc2 = new Account(Name='child2', Quickbooks_ID__c = '3');
        insert childAcc2;
    }

    @IsTest
    static void accountTriggerTest() {
        Account child2 = [SELECT Id, Name, Quickbooks_ID__c, ParentId  FROM Account WHERE Name ='child2' ];
        child2.ParentId = [SELECT id FROM Account WHERE Name = 'testParent'].id;

        Test.startTest();
        update child2;
        Test.stopTest();
    }
}