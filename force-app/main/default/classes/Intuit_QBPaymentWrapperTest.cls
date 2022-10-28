/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_QBPaymentWrapperTest {

    @IsTest
    static void testParsePass(){
        Test.startTest();
        Intuit_QBPaymentWrapper newPayment = Intuit_QBPaymentWrapper.jsonParse(Intuit_MockResponse.getQBPaymentFullResp().getBody());
        Test.stopTest();
        System.debug(Intuit_MockResponse.getQBPaymentFullResp().getBody());
        System.debug(newPayment);

        System.assert(newPayment!= null);
    }

    @IsTest
    static void testParseFail(){
        String exceptionMsg;
        try {
            Test.startTest();
            Intuit_QBPaymentWrapper newCustomer = Intuit_QBPaymentWrapper.jsonParse('');
            Test.stopTest();
        } catch(Exception e) {
            exceptionMsg = e.getMessage();
        }

        System.assert(exceptionMsg != null);
    }
}