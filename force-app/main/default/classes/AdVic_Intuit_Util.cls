/**
 * Created by sean.wallace on 8/26/22.
 */
public class AdVic_Intuit_Util{
    @future(Callout=true)
    public static void refreshAccessToken() {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_Configuration__c[] quickbooksConfiguration;
        try {

            quickbooksConfiguration = [
                SELECT
                        Id, refreshToken__c, isActive__c
                FROM Quickbooks_Configuration__c
                WHERE configId__c = : (isSandbox ? 'Sandbox' : 'Production')
                LIMIT 1
            ];
            if(quickbooksConfiguration.size() == 0 || !quickbooksConfiguration[0].isActive__c){
                throw new QB_Exception('Quickbooks Configuration record is not active, invalid, or doesn\'t exist');
            }
            else {
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');
                request.setEndpoint('callout:Quickbooks/oauth2/v1/tokens/bearer');
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                String payload = 'grant_type=refresh_token&refresh_token=' + EncodingUtil.urlEncode(quickbooksConfiguration[0].refreshToken__c, 'UTF-8');
                request.setBody(payload);

                Http http = new Http();
                HttpResponse response = http.send(request);
                Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if (response.getStatusCode() != 200) {
                    throw new QB_Exception((String) res.get('error'));
                }
                // pares the response
                // update Quickbooks_Configuration__c
                Quickbooks_Configuration__c updateConfig = new Quickbooks_Configuration__c(
                        Id = quickbooksConfiguration[0].Id,
                        refreshToken__c = (String) res.get('refresh_token'),
                        accessToken__c = (String) res.get('access_token'),
                        expiresIn__c = (Integer) res.get('expires_in'),
                        xRefreshTokenExpiresIn__c = (Integer) res.get('x_refresh_token_expires_in'),
                        tokenType__c = (String) res.get('token_type'),
                        error__c = null
                );
                update updateConfig;
            }
        } catch (Exception e){
            System.debug(e.getMessage());
            Quickbooks_Configuration__c updateConfig = new Quickbooks_Configuration__c(
                    Name = isSandbox ? 'Sandbox' : 'Production',
                    error__c = e.getMessage(),
                    configId__c = isSandbox ? 'Sandbox' : 'Production'
            );
            if(quickbooksConfiguration.size() != 0){
                updateConfig.Id = quickbooksConfiguration[0].Id;
            }
            System.debug(JSON.serializePretty(updateConfig));
            upsert updateConfig configId__c;
        }
    }

    public class QB_Exception extends Exception {}
}