/*
 *	@Purpose : Update Contact's State__c field. Based on value of State_Abbrv_Formula__c or State_Formula__c.
*	@Created Date : 23-03-2018
 */
trigger ContactTriggerToUpdateState on Contact (Before insert, Before update) {
    if( Trigger.isBefore ) {
        if( Trigger.isInsert ){
            ContactTriggerToUpdateStateHandler.updateContacts(Trigger.New);
        }
    }
    
    if( Trigger.isBefore){
        if( Trigger.isUpdate ){
            //Call tryUpdateContact() method to update State field's value of Contact   
            ContactTriggerToUpdateStateHandler.tryUpdateContact(Trigger.New,Trigger.oldMap);
        }
    }
}