public class OverlappingBlockOutDates{
    private List<Consultant_Block_Out_Dates__c> listConsultantBlockOutDates;
    public Boolean isUpdate; 
    
    public OverlappingBlockOutDates(List<Consultant_Block_Out_Dates__c> listNewConsultantBlockOutDates){
        listConsultantBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        listConsultantBlockOutDates.addAll(listNewConsultantBlockOutDates); 
        isUpdate = false; 
    }
        
    public void checkOverlapingDates(){
        
        Set<Id> setContactIds = new Set<Id>();
        Map<Id, Set<Date>> mapContactIdsNSetExistingDates;        
        
        OverlappingDates handler = new OverlappingDates(listConsultantBlockOutDates, isUpdate);       
        
        // Create set of all Consultant Contacts from Trigger.new(new/updated records)
        for(Consultant_Block_Out_Dates__c consultantBlockOutDate : listConsultantBlockOutDates){
            setContactIds.add(consultantBlockOutDate.Consultant_Contact__c);
        }
        System.debug('setContactIds : ' + setContactIds);
        
        // Create list of all existing Consultant Booked Dates from Opportunity records.
        List<Eligible_Consultant__c> listExistingConsultantBookedDates;
        if(!setContactIds.isEmpty()){
        
            listExistingConsultantBookedDates = handler.getListExistingConsultantBookedDates(setContactIds);
        }
        System.debug('listExistingConsultantBookedDates : ' + listExistingConsultantBookedDates);
        
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
        if((listExistingConsultantBookedDates != NULL && !listExistingConsultantBookedDates.isEmpty()) ||
        (listOpportunityBookedDates != NULL && !listOpportunityBookedDates.isEmpty()) ||
        (listExistingConsultantBlockOutDates != NULL && !listExistingConsultantBlockOutDates.isEmpty())){
            mapContactIdsNSetExistingDates = new Map<Id, Set<Date>>();
            mapContactIdsNSetExistingDates = handler.createSetOfStartEndDates(listExistingConsultantBookedDates, 
                                                                              listExistingConsultantBlockOutDates,
                                                                              listOpportunityBookedDates);            
        }
        
        if(mapContactIdsNSetExistingDates != NULL && !mapContactIdsNSetExistingDates.isEmpty()){
            handler.compareBlockOutDatesWithExistingDates(mapContactIdsNSetExistingDates);            
        }
    }    
}