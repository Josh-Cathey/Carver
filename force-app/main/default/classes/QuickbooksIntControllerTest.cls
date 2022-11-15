@isTest
public with sharing class QuickbooksIntControllerTest {

    @isTest
    static void testSaveKeyAndSecret(){
        String clientId = '12345678910abc';
        String clientSecret = '10987654321bca';
        try {
            QuickbooksIntController.saveKeyAndSecret(clientId, clientSecret);
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }

    @isTest
    static void testGetAuthDone() {
        String redirect_URI = 'https://carver--partialtf.sandbox.lightning.force.com/c/QuickbooksAccessRefresh.app';
        String authCodeFromURL = 'qwertyuiopasdfghjklzxcvbnm12345678910z';
        Quickbooks_Configuration__c qbConfig = new Quickbooks_Configuration__c();
        qbConfig.accessToken__c = '1234567899876543210';
        qbConfig.Consumer_Key__c = '12345678910abc';
        qbConfig.Consumer_Secret__c = '10987654321bca';
        qbConfig.isActive__c = true;
        qbConfig.Name = 'Sandbox';
        qbConfig.expiresIn__c = 3600;
        qbConfig.configId__c = '200';
        insert qbConfig;
        
        try {
            QuickbooksIntController.getAuthDone(redirect_URI, authCodeFromURL);
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
}