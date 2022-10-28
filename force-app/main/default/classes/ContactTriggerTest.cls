@isTest
public class ContactTriggerTest {
     
    static testMethod void setupData() {
        Contact contactRec1 = new Contact(Salutation = 'Mr.', FirstName = 'Test1', LastName = 'Last1', Travel_Admin__c = UserInfo.getUserId(), Consultant_Status__c='Profile in Review');
        insert contactRec1;
        //System.assertEquals(1, [SELECT count() FROM ProcessInstance]);
        
        Contact contactRec2 = new Contact(Salutation = 'Mr.', FirstName = 'Test2', LastName = 'Last2', Travel_Admin__c = UserInfo.getUserId(), Consultant_Status__c='Profile Pending');
        insert contactRec2;
        
        contactRec2 = [SELECT Id, Name, Consultant_Status__c FROM Contact WHERE Id =: contactRec2.Id];
        contactRec2.Consultant_Status__c = 'Profile in Review';
        update contactRec2;
        
        //System.assertEquals(2, [SELECT count() FROM ProcessInstance]);
    }
}