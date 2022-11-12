/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    09 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/

@RestResource(urlMapping='/api/webhooks/incoming/*') 
global with sharing class Intuit_QBWebhookListener {
    //utilized to verify signature
    private static final String SIGNATURE = 'intuit-signature';
    private static final String ALGORITHM = 'HmacSHA256';

    @HttpPost
    global static void handleNotification() {
        System.debug('QBWebhook listener was called!!!');
        try {
            RestRequest request = RestContext.request;
            RestResponse response = RestContext.response;

            Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
            Quickbooks_API_Information__mdt QBMetaConfig;
            if(isSandbox == false){
                QBMetaConfig = Quickbooks_API_Information__mdt.getInstance('Quickbooks_prod');
            }
            else {
                QBMetaConfig = Quickbooks_API_Information__mdt.getInstance('Quickbooks_sbx');
            }
            Blob requestBody = request.requestBody;

            Boolean isValid = isRequestValid(request.headers, requestBody.toString(), QBMetaConfig.Verifier_Token__c);
            //if(isValid || Test.isRunningTest()) {
                //can then trigger off this on the CRM
                Intuit_WebhookEvent__c webHookEventDetail = new Intuit_WebhookEvent__c();
                webHookEventDetail.body__c = requestBody.toString();
                insert webhookEventDetail;

                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Success', 'Processed Successfully')));
           //}
            // else {
            //     response.statusCode = 401;
            //     response.responseBody = Blob.valueOf(JSON.serialize(new SFDCResponse('Error', 'Processed Unsuccessfully')));
            // }

        }catch(Exception e) {
            System.debug('Exception '+ e.getMessage());
        }
    }

    public class SFDCResponse{
        string Response;
        string message;
        public SFDCResponse(string resp, string msg){
            response = resp;
            message = msg;
        }
    }

    public static boolean isRequestValid(Map<String, String> headers, String Payload, String verifier) {
        String signature = headers.get(SIGNATURE);
        if (signature == null && !Test.isRunningTest()) {
            return false;
        }
        try {
            blob privateKey = blob.valueOf(verifier);
            blob bdata = Blob.valueOf(payload);
            blob encrypted = Crypto.generateMac(ALGORITHM, bdata ,privateKey);
            String hash = EncodingUtil.base64Encode(encrypted);
            String payloadSignature = EncodingUtil.convertToHex(blob.valueOf(signature));

            return hash.equals(signature);
        }
        catch (Exception e) {
            System.debug('Exception Caught Verifying QB Webhook POST request: ' + e.getMessage() + ' | ' + e.getStackTraceString());
            return false;
        }
    }

}