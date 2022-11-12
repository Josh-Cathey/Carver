/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    11 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_QBCustomerWrapperTest {

    @IsTest
    static void testParsePass(){
        Test.startTest();
       	Intuit_QBCustomerWrapper newCustomer = Intuit_QBCustomerWrapper.jsonParse(Intuit_MockResponse.getQBCustomerFullResp().getBody());
        Test.stopTest();
        System.debug(Intuit_MockResponse.getQBCustomerFullResp().getBody());
        System.debug(newCustomer);

        System.assert(newCustomer!= null);
    }

    @IsTest
    static void testParseFail(){
        String exceptionMsg;
        try {
            Test.startTest();
            Intuit_QBCustomerWrapper newCustomer = Intuit_QBCustomerWrapper.jsonParse('');
            Test.stopTest();
        } catch(Exception e) {
            exceptionMsg = e.getMessage();
        }

        System.assert(exceptionMsg != null);
    }
}