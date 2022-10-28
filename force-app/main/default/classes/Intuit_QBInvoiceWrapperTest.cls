/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    12 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
public class Intuit_QBInvoiceWrapperTest {

    @IsTest
    static void testParsePass(){
        Test.startTest();
        Intuit_QBInvoiceWrapper newInvoice = Intuit_QBInvoiceWrapper.jsonParse(Intuit_MockResponse.getQBInvoiceFullResp().getBody());
        Test.stopTest();
        System.debug(Intuit_MockResponse.getQBCustomerFullResp().getBody());
        System.debug(newInvoice);

        System.assert(newInvoice!= null);
    }

    @IsTest
    static void testParseFail(){
        String exceptionMsg;
        try {
            Test.startTest();
            Intuit_QBInvoiceWrapper newCustomer = Intuit_QBInvoiceWrapper.jsonParse('');
            Test.stopTest();
        } catch(Exception e) {
            exceptionMsg = e.getMessage();
        }

        System.assert(exceptionMsg != null);
    }
}