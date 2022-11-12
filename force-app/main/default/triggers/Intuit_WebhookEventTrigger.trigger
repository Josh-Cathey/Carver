trigger Intuit_WebhookEventTrigger on Intuit_WebhookEvent__c (after insert) {
    Intuit_WebhookEventTriggerHandler.insertQBCreditMemoRecord();
}