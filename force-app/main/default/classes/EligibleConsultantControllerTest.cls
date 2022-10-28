@isTest
public class EligibleConsultantControllerTest{    
    
    private static String accountJsonResponseBody='{'
        +'"account_sid": "AC03c2fcd60e144e7cbeee413fcbf812a3",'
        +'"api_version": "2010-04-01",'
        +'"body": "Test sending MMS from twilio",'
        +'"num_segments": "1",'
        +'"num_media": "1",'
        +'"date_created": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_sent": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"date_updated": "Mon, 1 Feb 2012 10:49:17 +0000",'
        +'"direction": "outbound-api",'
        +'"from": "+14158141829",'
        +'"price": "null",'
        +'"price_unit":"usd",'
        +'"sid": "MM90c6fc909d8504d45ecdb3a3d5b3556e",'
        +'"status": "queued",'
        +'"to": "+14159978453",'
        +'"uri": "/2010-04-01/Accounts/AC03c2fcd60e144e7cbeee413fcbf812a3/MM90c6fc909d8504d45ecdb3a3d5b3556e.json",'
        +'"subresource_uris": '
        +'{"media":"/2010-04-01/Accounts/ACadfb5891c0e4f8c6c34be620a8ec1ef3/Messages/MMbd2135c6d10f417faf1e03fac4e8397b/Media.json"}'
        +'}';
    
    @testSetup
    public static void setupTestData(){
        
        Account account = new Account();
        account.Name = 'Test Account';
        account.Family_Brand__c = 'Other';
        insert account;
        
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consultants').getRecordTypeId();
        
        Contact consultant = new Contact();        
        consultant.AccountId = account.Id;
        consultant.Consultant_Status__c = 'Active';
        consultant.LastName = 'Test Consultant';
        consultant.Phone = '+14158141829';
        consultant.CI_TY__c = true;
        consultant.Delphi__c = false;
        consultant.Envision__c = true;
        consultant.ISAC__c = false;
        consultant.SalesPro__c = true;
        consultant.Task_Force__c = True;
        consultant.RecordTypeId = RecordTypeIdContact;
        insert consultant;
        
        Brands__c brand = new  Brands__c();
        brand.Consultant_Contact__c = consultant.Id;
        brand.Family_of_Brands__c = 'Other';
        insert brand;
        
        Product2 product = new Product2();
        product.Name = 'Test Product';
        product.IsActive = true;
        insert product;        
        
        Service_Positions__c servicePosition = new Service_Positions__c();
        servicePosition.Name = 'Test Service Position';
        servicePosition.Consultant_Contact__c = consultant.Id;
        servicePosition.Position_Title__c = 'Controller II';   
        servicePosition.Service_Position__c = product.Id;        
        insert servicePosition;   
        
        Opportunity consultantContact = new Opportunity();
        consultantContact.AccountId = account.Id;
        consultantContact.Service_Start_Date__c = Date.valueOf('2016-02-12');
        consultantContact.Service_End_Date__c = Date.valueOf('2016-02-14');    
        consultantContact.Name = 'Test Consultant Contact';
        consultantContact.CloseDate = Date.valueOf('2017-03-21');
        consultantContact.StageName = 'Needs Analysis';        
        insert consultantContact;
        
        Consultant_Block_Out_Dates__c consultantBlockOutDate = new Consultant_Block_Out_Dates__c();
        consultantBlockOutDate.Consultant_Contact__c = consultant.Id;
        consultantBlockOutDate.Not_Available_Start_Date__c = Date.valueOf('2016-03-01');
        consultantBlockOutDate.Not_Available_End_Date__c = Date.valueOf('2016-03-10');
        consultantBlockOutDate.Not_Available_Details__c = 'Test';
        insert consultantBlockOutDate;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp-1';
        opp.AccountId = account.Id;
        opp.Primary_Contact__c = consultant.Id;
        opp.CloseDate = Date.valueOf('2017-03-21');
        opp.StageName = 'Needs Analysis';
        opp.Service_Start_Date__c = Date.valueOf('2016-04-12');
        opp.Service_End_Date__c = Date.valueOf('2016-04-14');  
        insert opp;
        
        Opportunity opp2 = new Opportunity();
        opp2.Name = 'Test Opp-2';
        opp2.AccountId = account.Id;
        opp2.Primary_Contact__c = consultant.Id;
        opp2.CloseDate = Date.valueOf('2017-03-21');
        opp2.StageName = 'Needs Analysis';
        opp2.Service_Start_Date__c = Date.valueOf('2016-06-12');
        opp2.Service_End_Date__c = Date.valueOf('2016-06-14');  
        insert opp2;
        
        Id stdPriceBookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry();
        pbe.IsActive = true;
        pbe.Pricebook2Id = stdPriceBookId;
        pbe.Product2Id = product.Id;
        pbe.UnitPrice = 100.00;
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();       
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 2;
        oli.TotalPrice = 1000.00;
        insert oli; 
        
        OpportunityLineItem oli2 = new OpportunityLineItem();       
        oli2.OpportunityId = opp2.Id;
        oli2.PricebookEntryId = pbe.Id;
        oli2.Quantity = 2;
        oli2.TotalPrice = 1000.00;
        insert oli2; 
        
        Eligible_Consultant__c eligibleConsultant = new Eligible_Consultant__c();
        eligibleConsultant.Consultant__c = consultant.Id;
        eligibleConsultant.Opportunity__c = opp.Id;
        insert eligibleConsultant; 
        
        TwilioConfig__c auth = new TwilioConfig__c();
        auth.Name = 'Live';
        auth.AccountSid__c = 'ACadfb5891c0e4f8c6c34be620a8ec1ef3';
        auth.AuthToken__c = '12345678901234567890123456789012';
        auth.TwilioNumber__c = '+14159978453';
        insert auth;      
        
    }     
    
    public static testmethod void testEligibleConsultant(){       
                
        Twilio_TestHTTPMock.getInstance().putResponse('POST',
                                                      'https://api.twilio.com/2010-04-01/Accounts/ACadfb5891c0e4f8c6c34be620a8ec1ef3/Messages.json',
                                                      new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200));
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp-2' LIMIT 1];   
        Contact consultant = [SELECT Id FROM Contact WHERE Name = 'Test Consultant' LIMIT 1];
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp);
        
        EligibleConsultantController controller = new EligibleConsultantController(stdController);
        controller.getEligibleConsultant();
        List<String> listConsultantIds = new List<String>();
        listConsultantIds.add(consultant.Id);
       
        EligibleConsultantController.createEligibleConsultants(listConsultantIds, opp.Id);
        listConsultantIds = new List<String>();
        listConsultantIds.add(consultant.Id);
        
        String msg = EligibleConsultantController.sendSMS(listConsultantIds, opp.Id, '');     
        
        System.assert(!controller.eligibleConsultant.isEmpty());
        System.assertEquals(msg, 'SMS Sent Successfully!!!');
        
    }
    
    public static testmethod void testEligibleConsultantNeg1(){
        
        Twilio_TestHTTPMock.getInstance().putResponse('POST',
                                                      'https://api.twilio.com/2010-04-01/Accounts/ACadfb5891c0e4f8c6c34be620a8ec1ef3/Messages.json',
                                                      new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200));
        
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp-1' LIMIT 1];   
        Contact consultant = [SELECT Id,Phone FROM Contact WHERE Name = 'Test Consultant' LIMIT 1];   
        
        List<Id> listConsultantIds = new List<Id>();
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', '');        
        ApexPages.StandardController stdController = new ApexPages.StandardController(consultant);        
        EligibleConsultantController controller = new EligibleConsultantController(stdController);
        controller.getEligibleConsultant();        
        listConsultantIds.add(consultant.Id);
        String msg = EligibleConsultantController.sendSMS(listConsultantIds, '', '');
        
        System.assert(controller.opp == NULL);
        System.assert(msg.contains('Error'));
    }  
    
    public static testmethod void testEligibleConsultantNeg2(){
        
        Twilio_TestHTTPMock.getInstance().putResponse('POST',
                                                      'https://api.twilio.com/2010-04-01/Accounts/ACadfb5891c0e4f8c6c34be620a8ec1ef3/Messages.json',
                                                      new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200));
        
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp-1' LIMIT 1];   
        Contact consultant = [SELECT Id,Phone FROM Contact WHERE Name = 'Test Consultant' LIMIT 1];
        consultant.Phone = '';        
        update consultant;
        
        Consultant_Block_Out_Dates__c blockoutDate = new Consultant_Block_Out_Dates__c();
        blockoutDate.Not_Available_Start_Date__c = Date.valueOf('2016-05-10');
        blockoutDate.Not_Available_End_Date__c = Date.valueOf('2016-05-13');
        blockoutDate.Consultant_Contact__c = consultant.Id;
        insert blockoutDate;
        
        List<Id> listConsultantIds = new List<Id>();        
        ApexPages.currentPage().getParameters().put('id', opp.Id);        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp); 
        EligibleConsultantController controller = new EligibleConsultantController();
        controller = new EligibleConsultantController(stdController);
        controller.getEligibleConsultant();          
        String msg = EligibleConsultantController.sendSMS(listConsultantIds, opp.Id, '');   
        
        //System.assert(!controller.eligibleConsultant.isEmpty());
        System.assertEquals(msg, 'Error - Message sending failed!!!');
    }
    
    public static testmethod void testConsultantWithoutPhone(){
        
        Twilio_TestHTTPMock.getInstance().putResponse('POST',
                                                      'https://api.twilio.com/2010-04-01/Accounts/ACadfb5891c0e4f8c6c34be620a8ec1ef3/Messages.json',
                                                      new Twilio_TestHTTPMock.Response(accountJsonResponseBody,200));
        
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp-2' LIMIT 1];   
        Contact consultant = [SELECT Id,Phone FROM Contact WHERE Name = 'Test Consultant' LIMIT 1];
        consultant.Phone = '';
        update consultant;
        
        List<Id> listConsultantIds = new List<Id>();
        listConsultantIds.add(consultant.Id);
        ApexPages.currentPage().getParameters().put('id', opp.Id);        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp); 
        EligibleConsultantController controller = new EligibleConsultantController(stdController);
        controller.getEligibleConsultant();           
        
        String msg = EligibleConsultantController.sendSMS(listConsultantIds, opp.Id,'');   
        
        System.assertEquals(controller.eligibleConsultant[0].recordId, consultant.Id);
        System.assertEquals('Error - Consultant Phone number is missing!!!', msg);
    }
    
    public static testmethod void testTwilioNeg(){       
        
        PageReference eligibleConsultantPage = Page.EligibleConsultant;
        Test.setCurrentPage(eligibleConsultantPage);
        
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opp-1' LIMIT 1];   
        Contact consultant = [SELECT Id,Phone FROM Contact WHERE Name = 'Test Consultant' LIMIT 1];
        
        List<Id> listConsultantIds = new List<Id>();
        listConsultantIds.add(consultant.Id);
        ApexPages.currentPage().getParameters().put('id', opp.Id);        
        ApexPages.StandardController stdController = new ApexPages.StandardController(opp); 
        EligibleConsultantController controller = new EligibleConsultantController(stdController);
        
        controller.getEligibleConsultant();          
        String msg = EligibleConsultantController.sendSMS(listConsultantIds, opp.Id, '');  
        System.assert(msg.contains('Error'));
    }
}