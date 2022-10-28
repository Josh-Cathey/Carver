trigger OpportunityTrigger on Opportunity (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        List<Opportunity> listConsultantBookedDates = new List<Opportunity>();
        
        for(Opportunity consultantBookedDate : Trigger.new){
            
            if(consultantBookedDate.StageName != NULL && (!consultantBookedDate.StageName.equalsIgnoreCase('Closed Lost')) 
                && (consultantBookedDate.Service_Start_Date__c != NULL && consultantBookedDate.Service_End_Date__c != NULL 
                && consultantBookedDate.Consultant_Assigned__c != NULL)
                && (consultantBookedDate.Service_Start_Date__c <= consultantBookedDate.Service_End_Date__c)){
                listConsultantBookedDates.add(consultantBookedDate);
            }            
        }
        
        if(!listConsultantBookedDates.isEmpty()){
            OverlappingBookedDates handler = new OverlappingBookedDates(listConsultantBookedDates);            
            handler.checkOverlapingOppDates();
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Opportunity> listConsultantBookedDates = new List<Opportunity>();
        Date oldStartDate, oldEndDate;
        Id consultantContactId;
        for(Opportunity consultantBookedDate : Trigger.new){
        
            consultantContactId = Trigger.oldMap.get(consultantBookedDate.Id).Consultant_Assigned__c;
            oldStartDate = Trigger.oldMap.get(consultantBookedDate.Id).Service_Start_Date__c;
            oldEndDate = Trigger.oldMap.get(consultantBookedDate.Id).Service_End_Date__c;
            
            
            if(consultantBookedDate.StageName != NULL && (!consultantBookedDate.StageName.equalsIgnoreCase('Closed Lost')) 
                && (consultantBookedDate.Consultant_Assigned__c != NULL
                && consultantBookedDate.Service_Start_Date__c != NULL 
                && consultantBookedDate.Service_End_Date__c != NULL)
                && ((consultantBookedDate.Service_Start_Date__c!= oldStartDate)
                || (consultantBookedDate.Service_End_Date__c!= oldEndDate)
                || (consultantBookedDate.Consultant_Assigned__c != consultantContactId))
                && (consultantBookedDate.Service_Start_Date__c <= consultantBookedDate.Service_End_Date__c)){
                listConsultantBookedDates.add(consultantBookedDate);
            }            
        }
        
        if(!listConsultantBookedDates.isEmpty()){
            OverlappingBookedDates handler = new OverlappingBookedDates(listConsultantBookedDates);
            handler.isUpdate = Trigger.isUpdate;
            handler.checkOverlapingOppDates();
        }
    }
}