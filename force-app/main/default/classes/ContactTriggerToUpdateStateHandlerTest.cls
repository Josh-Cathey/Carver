/**
 *	@description: This class is used to Check the functionality of "ContactTriggerToUpdateStateHandler" class.
 *	@date   : 26-03-2018
 */
@isTest
public class ContactTriggerToUpdateStateHandlerTest {

    public static final Integer TOTALRECORDS = 200;
    
  /*
   *	@description - Create test records that are used while testing 'ContactTriggerToUpdateStateHandler' class.
   */
    public static testMethod void insertTestData() {
        
        List<Contact> contactList = new List<Contact>();
        
        //Insert Towing Vehicle records
        for(Integer index = 0 ; index < TOTALRECORDS ; index ++){
            if( index < 100){
                contactList.add(new Contact(Salutation = 'Mr.', 
                                            FirstName = 'Test' + index, 
                                            LastName = 'Last' + index, 
                                            Travel_Admin__c = UserInfo.getUserId(), 
                                            mailingState ='TX'));
            }else{
                contactList.add(new Contact(Salutation = 'Mr.', 
                                            FirstName = 'Test' + index, 
                                            LastName = 'Last' + index, 
                                            Travel_Admin__c = UserInfo.getUserId(), 
                                            mailingState ='Maryland'));
            }            
        }
        
        INSERT contactList ;
        
        contactList = [Select id, mailingState 
                       FROM Contact];
        
        System.assertEquals( TOTALRECORDS, contactList.size() );
        
        Test.startTest();
            // Update Contact records
            for(Contact contact : contactList){
                contact.mailingState = 'SC';
            }
            
            UPDATE contactList;
            
            // Update Contact records
            for(Contact contact : contactList){
                contact.mailingState = 'Alaska';
            }
            
            UPDATE contactList;
        
        Test.stopTest();
    } 
}