/*
Ad Victoriam Solutions - CarverBox
Purpose: 
Dependencies:
Changelog:
    05 Oct 2022 by Christian.Jimenez for JIRA-01
        - Created initial file.
*/
public class Intuit_SyncCallout {
//    public static HttpResponse queryQB(Quickbooks_API_Information__mdt meta, String authToken, String objectRecordType) {
//        //Temporary storage,TODO: move values away from static
//        HttpRequest req = new HttpRequest();
//        String endpoint = meta.Endpoint__c;
//
//        DateTime dt = DateTime.now() - 1;
//        String dateTimeStr = dt.format('yyyy-MM-dd');
//
//        //TODO Need to store this realm ID in a custom metadata
//        String realmId = meta.Realm_ID__c;
//        String urlParamStr = '/v3/carver/' + realmId + '/query?query=';
//        String quot = '\'';
//        quot = EncodingUtil.urlEncode(quot, 'UTF-8');
//        String queryString = 'SELECT DisplayName FROM ' + objectRecordType + ' WHERE Metadata.LastUpdatedTime = ' + quot + dateTimeStr + quot + '" ORDER BY Metadata.LastUpdatedTime';
//        queryString = queryString.replace(' ', '+');
//
//
//        req.setMethod('GET');
//        req.setEndpoint(endpoint + urlParamStr + queryString + '&minorversion=65');
//        req.setHeader('content-type', 'application/text');
//        req.setHeader('accept', 'application/json');
//        req.setHeader('authorization', authToken);
//
//        Http http = new Http();
//        HttpResponse response = http.send(req);
//        try {
//            String jsonBody = response?.toString();
//            System.debug('QuickBooks response' + jsonBody);
//        } catch (Exception e) {
//            System.debug('Exception Caught Sending QB Activity Query ' + objectRecordType + ' : ' + e.getMessage() + ' | ' + e.getStackTraceString());
//        }
//        //Parse the JSON
//        return response;
//    }

    //Utilized for Invoice and Customer record updates onto Quickbooks
    @future(callout=true)
    public static void sparseUpdateQB(String objectRecordType, String recordId, String fieldUpdate) {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_API_Information__mdt QBMetaConfig;
        String QBAccessToken;

        QBMetaConfig = isSandbox == false ? Quickbooks_API_Information__mdt.getInstance('Quickbooks_prod') : Quickbooks_API_Information__mdt.getInstance('Quickbooks_sbx');
        QBAccessToken = [SELECT Id, accessToken__c
                        FROM Quickbooks_Configuration__c
                        WHERE configId__c = :(isSandbox ? 'Sandbox' : 'Production')
                        LIMIT 1]?.accessToken__c;

        HttpRequest req = new HttpRequest();
        String endpoint = QBMetaConfig.endpoint__c;

        //An intial callout for a syncToken
        String syncToken = getSyncTokenValue(objectRecordType, recordId);
        String urlParamStr = '/v3/company/' + QBMetaConfig.Realm_ID__c + '/' + objectRecordType.toLowerCase() + '?minorversion=65';
        //String urlParamStr = '/v3/company/' + realmId + '/' + objectRecordType.toLowerCase() + '?minorversion=65';
        //String queryString = 'SELECT * from Account WHERE Metadata.LastUpdatedTime >\'2015-01-16\' Order By Metadata.LastUpdatedTime';

        req.setMethod('POST');
        req.setEndpoint(endpoint + urlParamStr);
        String body = generateBody(objectRecordType, recordId, syncToken, fieldUpdate);
        System.debug('body ' +body);
        req.setBody(body);
        req.setHeader('content-type', 'application/json');
        req.setHeader('accept', 'application/json');
        req.setHeader('authorization','bearer ' + QBAccessToken);

        Http http = new Http();
        HttpResponse response = http.send(req);
        try {
            String jsonBody = response?.toString();
            System.debug('QuickBooks Customer response' + jsonBody);
        } 
        catch (Exception e) {
            System.debug('Exception Caught Sending QB Account Query: ' + e.getMessage() + ' | ' + e.getStackTraceString());
            throw e;
        }
        System.debug(response.toString());
    }

    //ObjectRecordType == 'Invoice' or 'Customer' = (SF Account)
    @TestVisible
    public static String getSyncTokenValue(String objectRecordType, String recordId){
        String syncToken;
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_API_Information__mdt QBMetaConfig;
        String QBAccessToken;

        if (isSandbox == false) {
            QBMetaConfig = Quickbooks_API_Information__mdt.getInstance('Quickbooks_prod');
        }
        else {
            QBMetaConfig = Quickbooks_API_Information__mdt.getInstance('Quickbooks_sbx');
        }

        QBAccessToken = [SELECT Id, accessToken__c, configId__c
                        FROM Quickbooks_Configuration__c
                        WHERE configId__c =: (isSandbox? 'Sandbox': 'Production') LIMIT 1]?.accessToken__c;
        System.debug('QBmeta: ' + QBMetaConfig);
        System.debug('IsSandbox' + isSandbox);
        System.debug('AccessToken' + QBAccessToken);

        String realmId = QBMetaConfig.Realm_ID__c;
        String endpoint = QBMetaConfig.Endpoint__c;
        String urlParamStr = '/v3/company/' + realmId + '/'+ objectRecordType.toLowerCase() + '/' + recordId + '?minorversion=65';
        HttpRequest req = new HttpRequest();
        Http http = new Http();

        req.setMethod('GET');
        req.setHeader('accept', 'application/json');
        req.setEndpoint(endpoint + urlParamStr);
        req.setHeader('authorization','bearer ' + QBAccessToken);

        HttpResponse response = http.send(req);
        String jsonBody;

        try {
            jsonBody = response?.getBody();
            System.debug('QuickBooks SyncToken response' + jsonBody);
        } 
        catch (Exception e) {
            System.debug('Exception Caught getting syncToken Query: ' + e.getMessage() + ' | ' + e.getStackTraceString());
            throw e;
        }
        System.debug('response' + jsonBody);
        Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(jsonBody);
        Map<String, Object> data = (Map<String, Object>) res.get(objectRecordType);

        return data.get('SyncToken').toString();
    }

    @TestVisible
    private static String generateBody(String objectRecordType, String recordId, String syncToken, String fieldUpdate) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('Id' , recordId);
        gen.writeBooleanField('sparse', true);
        gen.writeStringField('SyncToken', syncToken);

        if (objectRecordType == 'Invoice') {
            gen.writeStringField('DocNumber', fieldUpdate);
        }
        else if (objectRecordType == 'Customer') {
            gen.writeBooleanField('Job', true);
            gen.writeBooleanField('BillWithParent', true);
            gen.writeFieldName('ParentRef');
            gen.writeStartObject();
            gen.writeStringField('value', fieldUpdate);
            gen.writeEndObject();
        }
        gen.writeEndObject();

        return gen.getAsString();
    }

}