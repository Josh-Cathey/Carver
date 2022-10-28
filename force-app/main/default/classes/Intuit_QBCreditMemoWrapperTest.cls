/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_QBCreditMemoWrapperTest {

    @IsTest
    static void testParsePass(){
        Test.startTest();
        Intuit_QBCreditMemoWrapper newCreditMemo = Intuit_QBCreditMemoWrapper.jsonParse(Intuit_MockResponse.getQBCreditMemoFullResp().getBody());
        Test.stopTest();
        System.debug(Intuit_MockResponse.getQBCreditMemoFullResp().getBody());
        System.debug(newCreditMemo);

        System.assert(newCreditMemo!= null);
    }

    @IsTest
    static void testParseFail(){
        String exceptionMsg;
        try {
            Test.startTest();
            Intuit_QBCreditMemoWrapper newCreditMemo = Intuit_QBCreditMemoWrapper.jsonParse('');
            Test.stopTest();
        } catch(Exception e) {
            exceptionMsg = e.getMessage();
        }

        System.assert(exceptionMsg != null);
    }
}