/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    16 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/

@IsTest
public class Intuit_SyncCalloutTest {

    @TestSetup
    static void setup(){

        Quickbooks_Configuration__c QB = new Quickbooks_Configuration__c(accessToken__c = 'test',
                configId__c ='Sandbox');
        Quickbooks_Configuration__c QB2 = new Quickbooks_Configuration__c(accessToken__c = 'test',
                configId__c ='Production');
        insert QB;
        insert QB2;

    }

    @IsTest
    static void testGenerateInvoiceBody(){
        String body;

        Test.startTest();
        body = Intuit_SyncCallout.generateBody('Invoice','130', '0', '120');
        Test.stopTest();
        System.debug('Body contents: ' + body);
        System.assert(body != null);
    }

    @IsTest
    static void testGenerateCustomerBody(){
        String body;

        Test.startTest();
        body = Intuit_SyncCallout.generateBody('Customer','130', '0', '12');
        Test.stopTest();
        System.debug('Body contents: ' + body);
        System.assert(body != null);
    }

    @IsTest
    static void testGetSyncTokenValue(){

        String syncToken;

        Test.setMock(HttpCalloutMock.class, new Intuit_CalloutMock());
        Test.startTest();
        syncToken = Intuit_SyncCallout.getSyncTokenValue('Invoice', '130');
        Test.stopTest();
        Assert.isTrue(syncToken.equals('9'),'Did not traverse to syncToken correctly- Incorrect SyncToken');
    }

    @IsTest
    static void testSparseUpdateQB(){

        Test.setMock(HttpCalloutMock.class, new Intuit_CalloutMock());
        Test.startTest();
        Intuit_SyncCallout.sparseUpdateQB('Customer', '1', '3');
        Test.stopTest();



    }

}