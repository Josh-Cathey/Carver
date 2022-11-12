@isTest
public with sharing class Intuit_WebhookEventTriggerHandlerTest {
    @isTest
    public static void testWebhookEventTrigger() {
        Intuit_WebhookEvent__c newWebhook = new Intuit_WebhookEvent__c();
        newWebhook.body__c = 'TESTING';
        try {
            insert newWebhook;
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        
    }
}
