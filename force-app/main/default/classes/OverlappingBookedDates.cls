public class OverlappingBookedDates{
    private List<Eligible_Consultant__c> listConsultantBookedDates;   
    private List<Opportunity> listConsultantOppBookedDates;    
    public Boolean isUpdate;
    
    public OverlappingBookedDates(List<Eligible_Consultant__c> listNewEligibleConsultants){
        listConsultantBookedDates = new List<Eligible_Consultant__c>();
        listConsultantBookedDates.addAll(listNewEligibleConsultants);  
        isUpdate = false;
    }

    public OverlappingBookedDates(List<Opportunity> listNewOpportunities){
        listConsultantOppBookedDates = new List<Opportunity>();
        listConsultantOppBookedDates.addAll(listNewOpportunities);  
        isUpdate = false;
    }
    
    public void checkOverlapingDates(){
        
        Set<Id> setContactIds = new Set<Id>();
        Map<Id, Set<Date>> mapContactIdsNSetExistingDates;       
        
        OverlappingDates handler = new OverlappingDates(listConsultantBookedDates, isUpdate);

        Set<Id> setOppIds = new Set<Id>();
        for(Eligible_Consultant__c consultantBookedDate : listConsultantBookedDates){
            setOppIds.add(consultantBookedDate.Opportunity__c);
        }

        Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id,StageName,Service_Start_Date__c, Service_End_Date__c
                                                                          FROM Opportunity
                                                                          WHERE Id IN :setOppIds
                                                                          AND StageName <> 'Closed Lost']);
        
        // Create set of all Consultant Contacts from Trigger.new(new/updated records)
        for(Eligible_Consultant__c consultantBookedDate : listConsultantBookedDates){
            if(mapOpportunities.containsKey(consultantBookedDate.Opportunity__c))
                setContactIds.add(consultantBookedDate.Consultant__c);
        }
        System.debug('setContactIds : ' + setContactIds);
        
        // Create list of all existing Consultant Booked Dates from Opportunity records.
        List<Eligible_Consultant__c> listEligibleConsultants;
        if(!setContactIds.isEmpty()){
            listEligibleConsultants = handler.getListExistingConsultantBookedDates(setContactIds);
        }
        System.debug('listEligibleConsultants : ' + listEligibleConsultants);

        /*List<Opportunity> listOpportunityBookedDates = new List<Opportunity>([SELECT Id,StageName,Service_Start_Date__c, 
                                                                                 Service_End_Date__c
                                                                                 FROM Opportunity
                                                                                 WHERE Consultant_Assigned__c IN :setContactIds
                                                                                 AND StageName <> 'Closed Lost']);*/
        // Create list of all existing Consultant Booked Dates from Opportunity records.
        List<Opportunity> listOpportunityBookedDates;
        if(!setContactIds.isEmpty()){
            listOpportunityBookedDates = handler.getListExistingConsultantOppBookedDates(setContactIds);
        }
        System.debug('listOpportunityBookedDates : ' + listOpportunityBookedDates);
        
        // Create list of all existing Consultant Block Out Dates from Consultant Block Out Dates records.
        List<Consultant_Block_Out_Dates__c> listExistingConsultantBlockOutDates;
        if(!setContactIds.isEmpty()){
            listExistingConsultantBlockOutDates = handler.getListExistingConsultantBlockOutDates(setContactIds);
        }
        System.debug('listExistingConsultantBlockOutDates : ' + listExistingConsultantBlockOutDates);
                
        // Create set of all exisiting dates
        if((listEligibleConsultants != NULL && !listEligibleConsultants.isEmpty()) 
            || (listExistingConsultantBlockOutDates != NULL && !listExistingConsultantBlockOutDates.isEmpty())
            || (listOpportunityBookedDates != NULL && !listOpportunityBookedDates.isEmpty())) {
            mapContactIdsNSetExistingDates = new Map<Id, Set<Date>>();
            mapContactIdsNSetExistingDates = handler.createSetOfStartEndDates(listEligibleConsultants, 
                                                                             listExistingConsultantBlockOutDates,
                                                                             listOpportunityBookedDates);            
        }
        
        if(mapContactIdsNSetExistingDates != NULL && !mapContactIdsNSetExistingDates.isEmpty()){
            handler.compareBookedDatesWithExistingDates(mapContactIdsNSetExistingDates,mapOpportunities);            
        }
    }    

    public void checkOverlapingOppDates(){
        
        Set<Id> setContactIds = new Set<Id>();
        Map<Id, Set<Date>> mapContactIdsNSetExistingDates;       
        
        OverlappingDates handler = new OverlappingDates(listConsultantOppBookedDates, isUpdate);
        
        // Create set of all Consultant Contacts from Trigger.new(new/updated records)
        for(Opportunity consultantBookedDate : listConsultantOppBookedDates){
            if(!consultantBookedDate.StageName.equalsIgnoreCase('Closed Lost'))
                setContactIds.add(consultantBookedDate.Consultant_Assigned__c);
        }
        System.debug('setContactIds : ' + setContactIds);
        
        // Create list of all existing Consultant Booked Dates from Opportunity records.
        List<Opportunity> listExistingConsultantBookedDates;
        if(!setContactIds.isEmpty()){
            listExistingConsultantBookedDates = handler.getListExistingConsultantOppBookedDates(setContactIds);
        }
        System.debug('listExistingConsultantBookedDates : ' + listExistingConsultantBookedDates);

        List<Eligible_Consultant__c> listExistingECBookedDates;
        if(!setContactIds.isEmpty()){
            listExistingECBookedDates = handler.getListExistingConsultantBookedDates(setContactIds);
        }
        System.debug('listExistingECBookedDates : ' + listExistingECBookedDates);
        
        // Create list of all existing Consultant Block Out Dates from Consultant Block Out Dates records.
        List<Consultant_Block_Out_Dates__c> listExistingConsultantBlockOutDates;
        if(!setContactIds.isEmpty()){
            listExistingConsultantBlockOutDates = handler.getListExistingConsultantBlockOutDates(setContactIds);
        }
        System.debug('listExistingConsultantBlockOutDates : ' + listExistingConsultantBlockOutDates);
                
        // Create set of all exisiting dates
        if((listExistingConsultantBookedDates != NULL && !listExistingConsultantBookedDates.isEmpty())
            || (listExistingConsultantBlockOutDates != NULL && !listExistingConsultantBlockOutDates.isEmpty())
            || (listExistingECBookedDates != NULL && !listExistingECBookedDates.isEmpty())){
            mapContactIdsNSetExistingDates = new Map<Id, Set<Date>>();
            mapContactIdsNSetExistingDates = handler.createSetOfStartEndDates(listExistingECBookedDates,
                                                                              listExistingConsultantBlockOutDates,
                                                                              listExistingConsultantBookedDates);            
        }
        
        if(mapContactIdsNSetExistingDates != NULL && !mapContactIdsNSetExistingDates.isEmpty()){
            handler.compareOppBookedDatesWithExistingDates(mapContactIdsNSetExistingDates);            
        }
    }    
}