/**
 * Created by sean.wallace on 8/26/22.
 */

@IsTest
private class AdVic_Intuit_UtilTest {
    @IsTest
    static void testSchedulable() {
        Test.startTest();
        AdVic_IntuitRefresh advicIntuitRefresh = new AdVic_IntuitRefresh();
        String chron = '0 0 23 * * ?';
        System.schedule('Test Sched', chron, advicIntuitRefresh);
        Test.stopTest();
    }

    @IsTest
    static void testNoConfig() {
        SchedulableContext context = null;
        AdVic_IntuitRefresh advicIntuitRefresh = new AdVic_IntuitRefresh();
        advicIntuitRefresh.execute(context);

        Quickbooks_Configuration__c[] quickbooksConfigurations = [ SELECT Id, configId__c, error__c FROM Quickbooks_Configuration__c];
//        System.assertEquals(quickbooksConfigurations.size(), 1);
//        System.assertEquals(quickbooksConfigurations[0].error__c,'Quickbooks Configuration record is not active, invalid, or doesn\'t exist');
    }

    @IsTest
    static void testNotActive() {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_Configuration__c quickbooksConfiguration = new Quickbooks_Configuration__c(
                configId__c = (isSandbox ? 'Sandbox' : 'Production'),
                isActive__c = false
        );
        insert quickbooksConfiguration;
        SchedulableContext context = null;
        AdVic_IntuitRefresh advicIntuitRefresh = new AdVic_IntuitRefresh();
        advicIntuitRefresh.execute(context);

        Quickbooks_Configuration__c[] quickbooksConfigurations = [ SELECT Id, configId__c, error__c FROM Quickbooks_Configuration__c];
        System.assertEquals(quickbooksConfigurations.size(), 1);
        System.assertEquals(quickbooksConfigurations[0].configId__c, (isSandbox ? 'Sandbox' : 'Production'));
//        System.assertEquals(quickbooksConfigurations[0].error__c,'Quickbooks Configuration record is not active, invalid, or doesn\'t exist');
    }

    @IsTest
    static void testValidConfigSuccessResponse() {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_Configuration__c quickbooksConfiguration = new Quickbooks_Configuration__c(
                error__c = null,
                configId__c = (isSandbox ? 'Sandbox' : 'Production'),
                refreshToken__c = 'REFRESH_TOKEN',
                isActive__c = true
        );
        insert quickbooksConfiguration;
        Test.setMock(HttpCalloutMock.class, new RefreshTokenSuccess());
        Test.startTest();
            SchedulableContext context = null;
        AdVic_IntuitRefresh advicIntuitRefresh = new AdVic_IntuitRefresh();
            advicIntuitRefresh.execute(context);
        Test.stopTest();

    }

    @IsTest
    static void testValidConfigErrorResponse() {
        Boolean isSandbox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
        Quickbooks_Configuration__c quickbooksConfiguration = new Quickbooks_Configuration__c(
                error__c = null,
                configId__c = (isSandbox ? 'Sandbox' : 'Production'),
                refreshToken__c = 'REFRESH_TOKEN',
                isActive__c = true
        );
        insert quickbooksConfiguration;
        Test.setMock(HttpCalloutMock.class, new RefreshTokenError());
        Test.startTest();
            SchedulableContext context = null;
        AdVic_IntuitRefresh advicIntuitRefresh = new AdVic_IntuitRefresh();
            advicIntuitRefresh.execute(context);
        Test.stopTest();

    }

    public class RefreshTokenSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('success');
            response.setBody('{ "x_refresh_token_expires_in": 8716468, "access_token": "a_good_token", "refresh_token": "a_good_refresh_token", "token_type": "bearer", "expires_in": 3600 }');
            return response;
        }
    }

    public class RefreshTokenError implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('error');
            response.setBody('{"error": "unsupported_grant_type" }');
            return response;
        }
    }
}