public class AssignConsultant{
    
    public void assignConsultantToOpp(List<Eligible_Consultant__c> listEligibleConsultant){
        
        Set<Id> setOppIds = new Set<Id>();
        for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultant){
            setOppIds.add(eligibleConsultant.Opportunity__c);
        }
        
        if(!setOppIds.isEmpty()){
            Map<Id, Opportunity> mapOpportunities = new Map<Id, Opportunity>([SELECT Id, Consultant_Assigned__c 
                                                                              FROM Opportunity WHERE Id IN :setOppIds]);
            
            if(!mapOpportunities.isEmpty()){
                
                for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultant){
                    if(mapOpportunities.containsKey(eligibleConsultant.Opportunity__c)){
                        if(eligibleConsultant.Status__c == 'Selected'){
                            mapOpportunities.get(eligibleConsultant.Opportunity__c).Consultant_Assigned__c = eligibleConsultant.Consultant__c;
                        }
                        else{
                            mapOpportunities.get(eligibleConsultant.Opportunity__c).Consultant_Assigned__c = null;
                        }
                    }
                }
                
                try{
                    update mapOpportunities.values();
                }catch(Exception e){
                    System.debug('Error : ' + e.getLineNumber() + ' -- ' + e.getMessage());
                }
            }
        }
    }

}