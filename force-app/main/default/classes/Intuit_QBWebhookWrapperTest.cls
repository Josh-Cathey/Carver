/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    11 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public with sharing class Intuit_QBWebhookWrapperTest {

    @IsTest
    static void testParsePass(){
        Test.startTest();
        Intuit_QBWebhookWrapper newHookResponse = Intuit_QBWebhookWrapper.jsonparse(Intuit_MockResponse.getQBWebhook().getBody());
        Test.stopTest();

        System.debug(newHookResponse);
        System.assert(newHookResponse != null);
    }

    @IsTest
    static void testParseFail() {
        String exceptionMsg;

        try{
            Test.startTest();
            Intuit_QBWebhookWrapper newHookResponse = Intuit_QBWebhookWrapper.jsonparse(Intuit_MockResponse.getQBWebhook().getBody());
            Test.stopTest();
        } 
        catch(Exception e){
            exceptionMsg = e.getMessage();
        }
        //System.assert(exceptionMsg != null);
    }
}