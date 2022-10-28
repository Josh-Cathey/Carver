/*
 *	@Description : Handler for ContactTriggerToUpdateState trigger.
 *	@Created date : 26-03-2018
 */   
public class ContactTriggerToUpdateStateHandler {
    
   /*
    *	@Purpose : Check whether is State_Abbrv_Formula__c or State_Formula__c is changed or not. If it changed then call
	*			   updateContacts() method to update Contact records.
    * 	@Parameter: newContactList [List] , oldContactMap [Map]
    */   
    public static void tryUpdateContact(List<Contact> newContactList ,Map<Id,Contact> oldContactMap) {
        
        if( newContactList != NULL && !newContactList.isEmpty() && oldContactMap != NULL && !oldContactMap.isEmpty() ){
            
            List<Contact> updatedContactList = New  List<Contact>();
            //Get all values of State picklist
            List<String> statePicklistValueList = getStatePicklistValues();
            
            //Check State_Abbrv_Formula__c or State_Formula__c is changed or not.
            for(Contact newContact : newContactList){
                Contact oldContact =  oldContactMap.get(newContact.Id);
                
                System.debug('oldContact.State_Abbrv_Formula__c' + oldContact.State_Abbrv_Formula__c);
                System.debug('oldContact.State_Formula__c' + oldContact.State_Formula__c);
                
                if( (oldContact.State_Abbrv_Formula__c != newContact.State_Abbrv_Formula__c) 
                   && (newContact.State_Abbrv_Formula__c != NULL) &&  String.isNotBlank(newContact.State_Abbrv_Formula__c) ){
                       if(statePicklistValueList.contains(newContact.State_Abbrv_Formula__c)){
                           newContact.State__c = newContact.State_Abbrv_Formula__c;
                       }                       
                   }
                else
                    if( (oldContact.State_Formula__c != newContact.State_Formula__c) 
                       && (newContact.State_Formula__c != NULL) &&  String.isNotBlank(newContact.State_Formula__c) ){                           
                           if(statePicklistValueList.contains(newContact.State_Formula__c)){
                               newContact.State__c = newContact.State_Formula__c;
                           }
                       }
                
                if( String.isBlank(newContact.State_Abbrv_Formula__c) && String.isBlank(newContact.State_Formula__c)){
                    newContact.State__c ='';
                }
            }          
        }
    }
    
   /*
    *	@Purpose : Update Contact's State__c field. Based on value of State_Abbrv_Formula__c and State_Formula__c.
    * 	@Parameter: contactList [List]
    */   
    public static void updateContacts(List<Contact> contactList) {
        
        if( contactList != NULL && !contactList.isEmpty() ){
            
            //Get all values of State picklist
            List<String> statePicklistValueList = getStatePicklistValues();
            
            for( Contact contact : contactList){
                // Check if State_Abbrv_Formula__c or State_Formula__c field's value is present or not. If present one of them , then populate this 
                // value in State__c field.
                if( contact.State_Abbrv_Formula__c != NULL && String.isNotBlank(contact.State_Abbrv_Formula__c) ){                    
                    if(statePicklistValueList.contains(contact.State_Abbrv_Formula__c)){
                        contact.State__c = contact.State_Abbrv_Formula__c;
                    }
                }                
                else if( contact.State_Formula__c != NULL && String.isNotBlank(contact.State_Formula__c) ){                    
                    if(statePicklistValueList.contains(contact.State_Formula__c)){
                        contact.State__c = contact.State_Formula__c;
                    }
                }
                
                if( String.isBlank(contact.State_Formula__c) && String.isBlank(contact.State_Abbrv_Formula__c)){
                    contact.State__c ='';
                }
            }
        }
        
        try{
            //UPDATE contactList;
        }catch(Exception exp){
            System.debug('Error occured while updating Contact records' + exp.getMessage());
        }
    }
    
   /*
    *	@Purpose : Get State picklist values.
    * 	@Return  :  [List]
    */   
    public static List<String> getStatePicklistValues() {
        List<String> stateValueList = new List<String>();
        
        Schema.DescribeFieldResult fieldResult = Contact.State__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry value : picklistValueList){
            stateValueList.add(value.getLabel());
        }
        
        return stateValueList;
    }

}