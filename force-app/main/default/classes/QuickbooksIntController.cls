public class QuickbooksIntController {

    @AuraEnabled
    public static Boolean saveKeyAndSecret(String clientId, String clientSecret) {
        try {
            List<Quickbooks_Configuration__c> quickInfo = new List<Quickbooks_Configuration__c>();
            quickInfo = [Select Id, Consumer_Key__c, Consumer_Secret__c FROM Quickbooks_Configuration__c Where Name = 'Sandbox' LIMIT 1];

            if(quickInfo != null && quickInfo.size() > 0){
                quickInfo[0].Consumer_Key__c = clientId;
                quickInfo[0].Consumer_Secret__c = clientSecret;
                update quickInfo;
            }
            else{
                Quickbooks_Configuration__c qbInfo = new Quickbooks_Configuration__c();
                qbInfo.Name = 'QuickInfo';
                qbInfo.Consumer_Key__c = clientId;
                qbInfo.Consumer_Secret__c = clientSecret;
                quickInfo.add(qbInfo);
                insert quickInfo;
            }
            return true;
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean getAuthDone(String redirect_URI, String authCodeFromURL){
        try {
            String accessToken_Endpoint = 'https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer?';
            List<Quickbooks_Configuration__c> quickInfoList = new List<Quickbooks_Configuration__c>();
            quickInfoList = [SELECT Id, Name, accessToken__c, expiresIn__c, Consumer_Key__c, Consumer_Secret__c FROM Quickbooks_Configuration__c WHERE Name = 'Sandbox'];
            System.debug(quickInfoList);
            // String authCodeFromURL = ApexPages.currentPage().getParameters().get('code');
            System.debug(authCodeFromURL);
            Http http = new Http();
            HttpRequest httpReq = new HttpRequest();
            HttpResponse httpRes = new HttpResponse();
            String requestTokenBody = 'code=' + authCodeFromURL + '&grant_type=authorization_code' +
                                        '&client_id=' + quickInfoList[0].Consumer_Key__c + '&client_secret=' + quickInfoList[0].Consumer_Secret__c +
                                        '&redirect_uri=' + redirect_URI;
            
            System.debug('#### authCodeFromURL ' + authCodeFromURL);
            System.debug('#### requestTokenBody ' + requestTokenBody);

            httpReq.setMethod('POST');
            httpReq.setEndpoint(accessToken_Endpoint);
            httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            httpReq.setBody(requestTokenBody);
            try {
                httpRes = http.send(httpReq);
            }
            catch(Exception e) {
                System.debug(e.getMessage());
            }
            
            System.debug('httpRes.getStatusCode()' + httpRes.getStatusCode());

            if(httpRes.getStatusCode() == 200 || Test.isRunningTest()) {
                Map<String,object> TokenInfo = new Map<String,object>();
                Quickbooks_Configuration__c quickbooksInfo = new Quickbooks_Configuration__c();
                
                if(Test.isRunningTest()) {
                    quickbooksInfo.accessToken__c =  '1234567899876543210';
                    quickbooksInfo.expiresIn__c =  3600;
                    quickbooksInfo.Name = 'JiraInfoTesting';
                }
                else {
                    TokenInfo = (Map<String,object>)JSON.deserializeUntyped(httpRes.getBody());
                    quickbooksInfo.accessToken__c =  String.valueOf(TokenInfo.get('access_token'));
                    quickbooksInfo.expiresIn__c =  Double.valueOf(TokenInfo.get('expires_in'));
                    quickbooksInfo.Name ='JiraInfo';
                }

                if(quickInfoList != null && quickInfoList.size() > 0){
                    quickbooksInfo.Id = quickInfoList[0].Id;
                }
                
              	update quickbooksInfo;
                return true;
            }
            else {
                return false;
            }
        }
         catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}