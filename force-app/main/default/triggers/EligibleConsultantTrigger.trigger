trigger EligibleConsultantTrigger on Eligible_Consultant__c (before insert, after insert, before update, after update) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        for(Eligible_Consultant__c eligibleConsultant : Trigger.New){
            if(eligibleConsultant.Status__c == 'Selected'){
                listEligibleConsultant.add(eligibleConsultant);
            }
        }
        
        if(!listEligibleConsultant.isEmpty()){
            AssignConsultant handler = new AssignConsultant();
            handler.assignConsultantToOpp(listEligibleConsultant);
        }
    }

    if(Trigger.isAfter && Trigger.isUpdate){
        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        for(Eligible_Consultant__c eligibleConsultant : Trigger.New){
            if(eligibleConsultant.Status__c != Trigger.oldMap.get(eligibleConsultant.Id).Status__c){
                listEligibleConsultant.add(eligibleConsultant);
            }
        }
        
        if(!listEligibleConsultant.isEmpty()){
            AssignConsultant handler = new AssignConsultant();
            handler.assignConsultantToOpp(listEligibleConsultant);
        }
    }
    
     if(Trigger.isBefore && Trigger.isInsert){
        List<Eligible_Consultant__c> listConsultantBookedDates = new List<Eligible_Consultant__c>();
        
        for(Eligible_Consultant__c consultantBookedDate : Trigger.new){
            
            if(((consultantBookedDate.Interested__c != 'No' && consultantBookedDate.Status__c == 'Eligible') 
                || (consultantBookedDate.Interested__c == 'Yes' && consultantBookedDate.Status__c == 'Selected'))){
                listConsultantBookedDates.add(consultantBookedDate);
            }            
        }
        
        if(!listConsultantBookedDates.isEmpty()){
            OverlappingBookedDates handler = new OverlappingBookedDates(listConsultantBookedDates);            
            handler.checkOverlapingDates();
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Eligible_Consultant__c> listConsultantBookedDates = new List<Eligible_Consultant__c>();
        String strInterested, strStatus;
        Id consultantContactId;
        for(Eligible_Consultant__c consultantBookedDate : Trigger.new){
                    
            strInterested = Trigger.oldMap.get(consultantBookedDate.Id).Interested__c;
            strStatus = Trigger.oldMap.get(consultantBookedDate.Id).Status__c;           
            
            if(((consultantBookedDate.Interested__c != 'No' && consultantBookedDate.Status__c == 'Eligible') 
                || (consultantBookedDate.Interested__c == 'Yes' && consultantBookedDate.Status__c == 'Selected')) 
                && (consultantBookedDate.Status__c != strStatus || consultantBookedDate.Interested__c != strInterested)){
                listConsultantBookedDates.add(consultantBookedDate);
            }            
        }
        
        if(!listConsultantBookedDates.isEmpty()){
            OverlappingBookedDates handler = new OverlappingBookedDates(listConsultantBookedDates);
            handler.isUpdate = Trigger.isUpdate;
            handler.checkOverlapingDates();
        }
    }
}