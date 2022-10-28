/*
 * @Description A Trigger define an actions after insert new lead records.
 */
Trigger LeadTrigger on Lead (after insert, after update, after delete, after undelete) {
    
    /*
    @description Bellow code seperate the Leades whoes source is Recruiter only
    */
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHandler.createAccountAndContacts(Trigger.new);
    }
    
    /*
    @description Bellow code seperate the Leades whoes source is updated recently.
    */
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Lead> listLeads = new List<Lead>();
        Lead leadTempObj;
        for(Lead leadObj : Trigger.new) {
            leadTempObj = Trigger.oldMap.get(leadObj.ID);
            if(leadObj.Status != leadTempObj.Status) {
                listLeads.add(leadObj);
            }
        }
        LeadTriggerHandler.createAccountAndContacts(listLeads);
    }
    
    //--check if Trigger is called after DML operation.
    if(Trigger.isAfter) {
        //--Check if Trigger is called after insert operation
        if(Trigger.isInsert) {
            LeadPotentialRevenueRollup.afterInsertLead( Trigger.new );            
        }
        //--Check if Trigger is called after update operation
        if(Trigger.isUpdate) {        
            LeadPotentialRevenueRollup.afterUpdateLead( Trigger.newMap,Trigger.oldMap );
        }
        //--Check if Trigger is called after delete operation
        if(Trigger.isDelete) {
            LeadPotentialRevenueRollup.afterDeleteLead( Trigger.old );
        }    
        //--Check if Trigger is called after undelete operation
        if(Trigger.isUndelete) {
            LeadPotentialRevenueRollup.afterUndeleteLead( Trigger.new );
        }
    }  
}