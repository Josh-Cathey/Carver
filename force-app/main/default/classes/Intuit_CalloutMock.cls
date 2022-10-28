/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    16 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
@IsTest
global class Intuit_CalloutMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req){
        HttpResponse response = new HttpResponse();
        String endpoint = req.getEndpoint();
        System.debug('endpoint: '+ endpoint);

        if (endpoint.contains('invoice/130')) {
             response = Intuit_MockResponse.getQBReadInvoiceResp();
        }
        //Read Query
        if(endpoint.contains('customer/1')){
            response = Intuit_MockResponse.getQBReadCustomerResp();
        }
        //Update
        if(endpoint.contains('customer?minorversion=')){
            response = Intuit_MockResponse.getQBSparseUpdateCustomerResp();
        }


        System.debug('Mockresponse: ' + response);
        return response;
    }
}