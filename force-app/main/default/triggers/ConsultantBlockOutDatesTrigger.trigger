trigger ConsultantBlockOutDatesTrigger on Consultant_Block_Out_Dates__c (before insert, before update) {
    
    if(Trigger.isBefore && Trigger.isInsert){  
    
        List<Consultant_Block_Out_Dates__c> listNewConsultantBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
       
        for(Consultant_Block_Out_Dates__c  consultantBlockOutDate : Trigger.new){          
            
            if((consultantBlockOutDate.Not_Available_Start_Date__c != NULL && consultantBlockOutDate.Not_Available_End_Date__c != NULL 
                && consultantBlockOutDate.Consultant_Contact__c != NULL)
                && (consultantBlockOutDate.Not_Available_Start_Date__c <= consultantBlockOutDate.Not_Available_End_Date__c)){
                listNewConsultantBlockOutDates.add(consultantBlockOutDate);
            }            
        } 
        
        if(!listNewConsultantBlockOutDates.isEmpty()){
            OverlappingBlockOutDates handler = new OverlappingBlockOutDates(listNewConsultantBlockOutDates);
            handler.checkOverlapingDates();
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Consultant_Block_Out_Dates__c> listNewConsultantBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        Date oldStartDate, oldEndDate;
        Id consultantContactId;
        
        for(Consultant_Block_Out_Dates__c  consultantBlockOutDate : Trigger.new){
            consultantContactId = Trigger.oldMap.get(consultantBlockOutDate.Id).Consultant_Contact__c;
            oldStartDate = Trigger.oldMap.get(consultantBlockOutDate.Id).Not_Available_Start_Date__c;
            oldEndDate = Trigger.oldMap.get(consultantBlockOutDate.Id).Not_Available_End_Date__c;
            
            if((consultantBlockOutDate.Consultant_Contact__c != NULL
                && consultantBlockOutDate.Not_Available_Start_Date__c != NULL 
                && consultantBlockOutDate.Not_Available_End_Date__c != NULL)
                && ((consultantBlockOutDate.Not_Available_Start_Date__c!= oldStartDate)
                || (consultantBlockOutDate.Not_Available_End_Date__c!= oldEndDate)
                || (consultantBlockOutDate.Consultant_Contact__c != consultantContactId))
                && (consultantBlockOutDate.Not_Available_Start_Date__c <= consultantBlockOutDate.Not_Available_End_Date__c)){
                listNewConsultantBlockOutDates.add(consultantBlockOutDate);
            }            
        }
        
        if(!listNewConsultantBlockOutDates.isEmpty()){
            OverlappingBlockOutDates handler = new OverlappingBlockOutDates(listNewConsultantBlockOutDates);
            handler.isUpdate = Trigger.isUpdate;            
            handler.checkOverlapingDates();
        }
    }
}