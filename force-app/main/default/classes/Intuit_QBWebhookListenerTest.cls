@isTest
public class Intuit_QBWebhookListenerTest {
    
    @testSetup 
    public static void dataSetup() {
        Account acc = new Account(Name = 'IB Test Acc');
        insert acc;
    }

    @isTest 
    public static void testPost() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/api/webhooks/incoming/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(Intuit_MockResponse.getQBWebhook().getBody());
        
        RestContext.request = req;
   		RestContext.response= res;
        
        Test.startTest();
        Intuit_QBWebhookListener.handleNotification();
        Test.stopTest();
    }
}