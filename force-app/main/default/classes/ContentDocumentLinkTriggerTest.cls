/**
 * Created by Holden.Parker on 4/11/22.
 */

@IsTest
private class ContentDocumentLinkTriggerTest {

    @TestSetup
    static void testSetup() {
        Account account = new Account();
        account.Name = 'Account';
        insert account;

        Contact contact = new Contact();
        contact.AccountId = account.Id;
        contact.LastName = 'Contact';
        contact.email = 'test@advic.com';
        insert contact;

        Consultant_History__c consultantHistory = new Consultant_History__c();
        consultantHistory.Consultant__c = contact.Id;
        insert consultantHistory;
    }

    static final String VISIBILITY_ERROR_MESSAGE = 'Content Document Link Visibility not updated as expected!';

    @IsTest
    static void testConsultantHistoryDocumentLinkInsert() {
        Consultant_History__c consultantHistory = [SELECT Id FROM Consultant_History__c LIMIT 1];

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test_Picture';
        contentVersion.PathOnClient = '/' + contentVersion.Title + '.jpg';
        Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
        contentVersion.VersionData= bodyBlob;
        contentVersion.Origin = 'H';
        insert contentVersion;

        Test.startTest();
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'InternalUsers';
        contentDocumentLink.LinkedEntityId = consultantHistory.Id;
        contentDocumentLink.ContentDocumentId = [
                SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersion.Id
        ].ContentDocumentId;
        insert contentDocumentLink;
        Test.stopTest();

        ContentDocumentLink queriedContentDocumentLink = [
                SELECT Id, ShareType, LinkedEntityId, ContentDocumentId, Visibility
                FROM ContentDocumentLink WHERE Id = :contentDocumentLink.Id
        ];
        System.assertEquals(true, queriedContentDocumentLink.Visibility == 'AllUsers', VISIBILITY_ERROR_MESSAGE);
    }

}