public class OverlappingDates{
    private List<Consultant_Block_Out_Dates__c> listConsultantBlockOutDates; 
    private List<Eligible_Consultant__c> listConsultantBookedDates;    
    private List<Opportunity> listConsultantOppBookedDates;    
    private Set<Id> setNewEligibleConsultantIds;
    private Set<Id> setNewOppIds;
    private Set<Id> setNewBlockOutDateIds;
    private Set<Date> setBookedDates;
    private Set<Date> setBlockOutDates;
    
    public Boolean isUpdate;
    
    public OverlappingDates(List<Eligible_Consultant__c> listNewEligibleConsultants, Boolean isUpdate){
        listConsultantBookedDates = new List<Eligible_Consultant__c>();
        listConsultantBookedDates.addAll(listNewEligibleConsultants);  
        
        this.isUpdate = isUpdate;
        
        if(this.isUpdate){
            setNewEligibleConsultantIds = new Set<Id>();
            for(Eligible_Consultant__c consultantBookedDate : listConsultantBookedDates){
                setNewEligibleConsultantIds.add(consultantBookedDate.Id);            
            }
        }
    }  

    public OverlappingDates(List<Opportunity> listNewOpportunities, Boolean isUpdate){
        listConsultantOppBookedDates = new List<Opportunity>();
        listConsultantOppBookedDates.addAll(listNewOpportunities);  
        
        this.isUpdate = isUpdate;
        
        if(this.isUpdate){
            setNewOppIds = new Set<Id>();
            for(Opportunity consultantBookedDate : listConsultantOppBookedDates){
                setNewOppIds.add(consultantBookedDate.Id);            
            }
        }
    }   
    
    public OverlappingDates(List<Consultant_Block_Out_Dates__c> listNewConsultantBlockOutDates, Boolean isUpdate){
        listConsultantBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        listConsultantBlockOutDates.addAll(listNewConsultantBlockOutDates);        
        
        this.isUpdate = isUpdate;        
        
        if(this.isUpdate){
            setNewBlockOutDateIds = new Set<Id>();
            for(Consultant_Block_Out_Dates__c consultantBlockOutDate : listConsultantBlockOutDates){
                setNewBlockOutDateIds.add(consultantBlockOutDate.Id);           
            }
        }       
    }
    
    public List<Eligible_Consultant__c> getListExistingConsultantBookedDates(Set<Id> setContactIds){
        List<Eligible_Consultant__c> listEligibleConsultants = new List<Eligible_Consultant__c>();
        listEligibleConsultants = [SELECT Id, Opportunity__r.Service_Start_Date__c, Opportunity__r.Service_End_Date__c,
                                   Opportunity__r.StageName, Consultant__c
                                   FROM Eligible_Consultant__c
                                   WHERE Consultant__c IN :setContactIds
                                   AND (Interested__c <> 'No' AND Status__c = 'Eligible')
                                   AND Opportunity__r.Consultant_Assigned__c = ''
                                   AND Opportunity__r.StageName <> 'Closed Lost'];


        /*List<Opportunity> listExistingConsultantBookedDates;
        listExistingConsultantBookedDates = [SELECT Consultant_Assigned__c, Service_Start_Date__c, 
                                             Service_End_Date__c
                                             FROM Opportunity
                                             WHERE Consultant_Assigned__c IN :setContactIds
                                             AND StageName <> 'Closed Lost'];*/
        return listEligibleConsultants;
    }

    public List<Opportunity> getListExistingConsultantOppBookedDates(Set<Id> setContactIds){

        List<Opportunity> listExistingConsultantBookedDates;
        listExistingConsultantBookedDates = [SELECT Consultant_Assigned__c, Service_Start_Date__c, 
                                             Service_End_Date__c
                                             FROM Opportunity
                                             WHERE Consultant_Assigned__c IN :setContactIds                                                                                      
                                             AND StageName <> 'Closed Lost'];
        return listExistingConsultantBookedDates;
    }
    
    public List<Consultant_Block_Out_Dates__c> getListExistingConsultantBlockOutDates(Set<Id> setContactIds){
        List<Consultant_Block_Out_Dates__c> listExistingConsultantBlockOutDates;
        listExistingConsultantBlockOutDates = [SELECT Consultant_Contact__c, Not_Available_Start_Date__c, 
                                               Not_Available_End_Date__c
                                               FROM Consultant_Block_Out_Dates__c
                                               WHERE Consultant_Contact__c IN :setContactIds];
        return listExistingConsultantBlockOutDates;
    }
    
    public Map<Id, Set<Date>> createSetOfStartEndDates(List<Eligible_Consultant__c> listExistingConsultantBookedDates,
                                                       List<Consultant_Block_Out_Dates__c> listExistingConsultantBlockOutDates,
                                                       List<Opportunity> listExistingConsultantOppBookedDates){
        
        Map<Id, Set<Date>> mapContactIdsNSetExistingDates = new Map<Id, Set<Date>>();
        
        mapContactIdsNSetExistingDates = createSetBookedDates(listExistingConsultantBookedDates, mapContactIdsNSetExistingDates);
        System.debug('mapContactIdsNSetExistingDates : ' + mapContactIdsNSetExistingDates);

        mapContactIdsNSetExistingDates = createSetBookedDates(listExistingConsultantOppBookedDates, mapContactIdsNSetExistingDates);
        System.debug('mapContactIdsNSetExistingDates : ' + mapContactIdsNSetExistingDates);
        
        mapContactIdsNSetExistingDates = createSetBlockOutDates(listExistingConsultantBlockOutDates, mapContactIdsNSetExistingDates);        
        System.debug('mapContactIdsNSetExistingDates : ' + mapContactIdsNSetExistingDates);
     
        return mapContactIdsNSetExistingDates;
    }  
    
    public Map<Id, Set<Date>> createSetBookedDates(List<Eligible_Consultant__c> listExistingConsultantBookedDates, 
                                                    Map<Id, Set<Date>> mapContactIdsNSetExistingDates){        
        Date startDate;        
        Set<Date> setStartEndDates = new Set<Date>();  
        if(setBookedDates == NULL)
            setBookedDates = new Set<Date>();
        
        for(Eligible_Consultant__c consultantBookedDate : listExistingConsultantBookedDates){
            
            if(isUpdate == true && setNewEligibleConsultantIds != NULL 
                && !setNewEligibleConsultantIds.isEmpty() 
                && setNewEligibleConsultantIds.contains(consultantBookedDate.Id)){
                continue;
            }
            
            startDate = consultantBookedDate.Opportunity__r.Service_Start_Date__c;            
            
            if(startDate != NULL)
                setStartEndDates.add(startDate);                
        
            if(consultantBookedDate.Opportunity__r.Service_End_Date__c != NULL 
                && startDate  != NULL 
                && startDate <= consultantBookedDate.Opportunity__r.Service_End_Date__c){
                while(startDate != consultantBookedDate.Opportunity__r.Service_End_Date__c){
                    if(startDate != NULL){
                        startDate = startDate.addDays(1);
                        setStartEndDates.add(startDate);
                    }
                }
            }
            if(!setStartEndDates.isEmpty()){
                setBookedDates.addAll(setStartEndDates);
                
                if(mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant__c)){
                    mapContactIdsNSetExistingDates.get(consultantBookedDate.Consultant__c).addAll(setStartEndDates);
                } else{
                    mapContactIdsNSetExistingDates.put(consultantBookedDate.Consultant__c, new Set<Date>(setStartEndDates));
                }   
            }
        }
        System.debug('setBookedDates : ' + setBookedDates);
        
        return mapContactIdsNSetExistingDates;
    }

    public Map<Id, Set<Date>> createSetBookedDates(List<Opportunity> listExistingConsultantOppBookedDates, 
                                                    Map<Id, Set<Date>> mapContactIdsNSetExistingDates){        
        Date startDate;        
        Set<Date> setStartEndDates = new Set<Date>();  
        if(setBookedDates == NULL)
            setBookedDates = new Set<Date>();
        
        for(Opportunity consultantBookedDate : listExistingConsultantOppBookedDates){
            
            if(isUpdate == true && setNewOppIds != NULL 
                && !setNewOppIds.isEmpty() 
                && setNewOppIds.contains(consultantBookedDate.Id)){
                continue;
            }
            
            startDate = consultantBookedDate.Service_Start_Date__c;            
            
            if(startDate != NULL)
                setStartEndDates.add(startDate);                
        
            if(consultantBookedDate.Service_End_Date__c != NULL 
                && startDate  != NULL 
                && startDate <= consultantBookedDate.Service_End_Date__c){
                while(startDate != consultantBookedDate.Service_End_Date__c){
                    if(startDate != NULL){
                        startDate = startDate.addDays(1);
                        setStartEndDates.add(startDate);
                    }
                }
            }
            if(!setStartEndDates.isEmpty()){
                setBookedDates.addAll(setStartEndDates);
                
                if(mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant_Assigned__c)){
                    mapContactIdsNSetExistingDates.get(consultantBookedDate.Consultant_Assigned__c).addAll(setStartEndDates);
                } else{
                    mapContactIdsNSetExistingDates.put(consultantBookedDate.Consultant_Assigned__c, new Set<Date>(setStartEndDates));
                }   
            }
        }
        System.debug('setBookedDates : ' + setBookedDates);
        
        return mapContactIdsNSetExistingDates;
    }
    
    public Map<Id, Set<Date>> createSetBlockOutDates(List<Consultant_Block_Out_Dates__c> listExistingConsultantBlockOutDates, 
                                                      Map<Id, Set<Date>> mapContactIdsNSetExistingDates){
        Date startDate;        
        Set<Date> setStartEndDates = new Set<Date>();
        setBlockOutDates = new Set<Date>();
        
        for(Consultant_Block_Out_Dates__c consultantBlockOutDate : listExistingConsultantBlockOutDates){
            
            if(isUpdate && setNewBlockOutDateIds != NULL &&  !setNewBlockOutDateIds.isEmpty() && setNewBlockOutDateIds.contains(consultantBlockOutDate.Id)){
                continue;
            }
            
            startDate = consultantBlockOutDate.Not_Available_Start_Date__c;
            
            if(startDate != NULL)
                setStartEndDates.add(startDate);                
            
            if(consultantBlockOutDate.Not_Available_End_Date__c!= NULL && startDate  != NULL && startDate <= consultantBlockOutDate.Not_Available_End_Date__c){
                while(startDate != consultantBlockOutDate.Not_Available_End_Date__c){
                    if(startDate != NULL){
                        startDate = startDate.addDays(1);
                        setStartEndDates.add(startDate);
                    }
                }
            }
            
            if(!setStartEndDates.isEmpty()){
                setBlockOutDates.addAll(setStartEndDates);
                if(mapContactIdsNSetExistingDates.containsKey(consultantBlockOutDate.Consultant_Contact__c)){
                    mapContactIdsNSetExistingDates.get(consultantBlockOutDate.Consultant_Contact__c).addAll(setStartEndDates);
                } else{
                    mapContactIdsNSetExistingDates.put(consultantBlockOutDate.Consultant_Contact__c, new Set<Date>(setStartEndDates));
                } 
            }
        }
        System.debug('setBlockOutDates : ' + setBlockOutDates);
        
        return mapContactIdsNSetExistingDates;
    }

    public void compareBlockOutDatesWithExistingDates(Map<Id, Set<Date>> mapContactIdsNSetExistingDates){
        Date dateBetweenStartEndDate;
        Set<Date> setStartEndDates;
        
        for(Consultant_Block_Out_Dates__c consultantBlockOutDate : listConsultantBlockOutDates){
            
            if(mapContactIdsNSetExistingDates != NULL && mapContactIdsNSetExistingDates.containsKey(consultantBlockOutDate.Consultant_Contact__c)){
                dateBetweenStartEndDate = consultantBlockOutDate.Not_Available_Start_Date__c;         
                setStartEndDates = mapContactIdsNSetExistingDates.get(consultantBlockOutDate.Consultant_Contact__c);
                
                if(setStartEndDates != NULL && !setStartEndDates.isEmpty()){
                    if(setStartEndDates.contains(dateBetweenStartEndDate) && setBlockOutDates.contains(dateBetweenStartEndDate)){
                        consultantBlockOutDate.addError('Block Out Dates are already blocked.');                    
                    } 
                    
                    if(setStartEndDates.contains(dateBetweenStartEndDate) && setBookedDates.contains(dateBetweenStartEndDate)){
                        consultantBlockOutDate.addError('Consultant Not Available.');                    
                    } 
                    
                    while(dateBetweenStartEndDate != consultantBlockOutDate.Not_Available_End_Date__c){
                        dateBetweenStartEndDate = dateBetweenStartEndDate.addDays(1);
                        if(setStartEndDates.contains(dateBetweenStartEndDate) && setBlockOutDates.contains(dateBetweenStartEndDate)){
                            consultantBlockOutDate.addError('Block Out Dates are already blocked.');
                            break;
                        } 

                        if(setStartEndDates.contains(dateBetweenStartEndDate) && setBookedDates.contains(dateBetweenStartEndDate)){
                            consultantBlockOutDate.addError('Consultant Not Available.');
                            break;
                        }                       
                    }
                }
            }
        }
    }  
    
    public void compareBookedDatesWithExistingDates(Map<Id, Set<Date>> mapContactIdsNSetExistingDates, Map<Id, Opportunity> mapOpportunities){
        Date dateBetweenStartEndDate;
        Set<Date> setStartEndDates;
        
        for(Eligible_Consultant__c consultantBookedDate : listConsultantBookedDates){
            
            System.debug('consultantBookedDate.Name : ' + consultantBookedDate.Name);
            System.debug('consultantBookedDate.Consultant__c : ' + consultantBookedDate.Consultant__c);
            System.debug('compareBookedDatesWithExistingDates Condition-1  : ' + (mapOpportunities.containsKey(consultantBookedDate.Opportunity__c) 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c != NULL 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_End_Date__c != NULL));
            System.debug('compareBookedDatesWithExistingDates Condition-2  : ' + (mapContactIdsNSetExistingDates != NULL 
                && mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant__c)));
            

            if((mapOpportunities.containsKey(consultantBookedDate.Opportunity__c) 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c != NULL 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_End_Date__c != NULL)
                && (mapContactIdsNSetExistingDates != NULL 
                && mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant__c))){

                dateBetweenStartEndDate = mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c;       
                System.debug('dateBetweenStartEndDate : ' + dateBetweenStartEndDate);  
                setStartEndDates = mapContactIdsNSetExistingDates.get(consultantBookedDate.Consultant__c);
                System.debug('setStartEndDates : ' + setStartEndDates);
                
                if(setStartEndDates != NULL && !setStartEndDates.isEmpty()){
                    System.debug('In Condition true' + String.valueOf(setStartEndDates));
                    System.debug('compareBookedDatesWithExistingDates Condition-3  : ' + setStartEndDates.contains(dateBetweenStartEndDate));
                    if(setStartEndDates.contains(dateBetweenStartEndDate)){
                        consultantBookedDate.addError('Consultant Not Available.');                    
                    } 
                    
                    while(dateBetweenStartEndDate != mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c){
                        dateBetweenStartEndDate = dateBetweenStartEndDate.addDays(1);
                        if(setStartEndDates.contains(dateBetweenStartEndDate)){
                            consultantBookedDate.addError('Consultant Not Available.');
                            break;
                        }                      
                    }
                }
            }
        }
    }  

    /* public void compareOppBookedDatesWithExistingDates(Map<Id, Set<Date>> mapContactIdsNSetExistingDates){
        Date dateBetweenStartEndDate;
        Set<Date> setStartEndDates;
        
        for(Eligible_Consultant__c consultantBookedDate : listConsultantBookedDates){
            
            System.debug('consultantBookedDate.Name : ' + consultantBookedDate.Name);
            System.debug('consultantBookedDate.Consultant__c : ' + consultantBookedDate.Consultant__c);
            System.debug('compareBookedDatesWithExistingDates Condition-1  : ' + (mapOpportunities.containsKey(consultantBookedDate.Opportunity__c) 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c != NULL 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_End_Date__c != NULL));
            System.debug('compareBookedDatesWithExistingDates Condition-2  : ' + (mapContactIdsNSetExistingDates != NULL 
                && mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant__c)));
            

            if((mapOpportunities.containsKey(consultantBookedDate.Opportunity__c) 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c != NULL 
                && mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_End_Date__c != NULL)
                && (mapContactIdsNSetExistingDates != NULL 
                && mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant__c))){

                dateBetweenStartEndDate = mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c;       
                System.debug('dateBetweenStartEndDate : ' + dateBetweenStartEndDate);  
                setStartEndDates = mapContactIdsNSetExistingDates.get(consultantBookedDate.Consultant__c);
                System.debug('setStartEndDates : ' + setStartEndDates);
                
                if(setStartEndDates != NULL && !setStartEndDates.isEmpty()){
                    System.debug('In Condition true' + String.valueOf(setStartEndDates));
                    System.debug('compareBookedDatesWithExistingDates Condition-3  : ' + setStartEndDates.contains(dateBetweenStartEndDate));
                    if(setStartEndDates.contains(dateBetweenStartEndDate)){
                        consultantBookedDate.addError('Consultant Not Available.');                    
                    } 
                    
                    while(dateBetweenStartEndDate != mapOpportunities.get(consultantBookedDate.Opportunity__c).Service_Start_Date__c){
                        dateBetweenStartEndDate = dateBetweenStartEndDate.addDays(1);
                        if(setStartEndDates.contains(dateBetweenStartEndDate)){
                            consultantBookedDate.addError('Consultant Not Available.');
                            break;
                        }                      
                    }
                }
            }
        } */

    public void compareOppBookedDatesWithExistingDates(Map<Id, Set<Date>> mapContactIdsNSetExistingDates){
        Date dateBetweenStartEndDate;
        Set<Date> setStartEndDates;
        
        for(Opportunity consultantBookedDate : listConsultantOppBookedDates){
            
            if((consultantBookedDate.Service_Start_Date__c != NULL && consultantBookedDate.Service_End_Date__c != NULL)
                && (mapContactIdsNSetExistingDates != NULL 
                && mapContactIdsNSetExistingDates.containsKey(consultantBookedDate.Consultant_Assigned__c))){
                dateBetweenStartEndDate = consultantBookedDate.Service_Start_Date__c;         
                setStartEndDates = mapContactIdsNSetExistingDates.get(consultantBookedDate.Consultant_Assigned__c);
                
                if(setStartEndDates != NULL && !setStartEndDates.isEmpty()){
                    if(setStartEndDates.contains(dateBetweenStartEndDate)){
                        consultantBookedDate.addError('Consultant Not Available.');                    
                    } 
                    
                    while(dateBetweenStartEndDate != consultantBookedDate.Service_End_Date__c){
                        dateBetweenStartEndDate = dateBetweenStartEndDate.addDays(1);
                        if(setStartEndDates.contains(dateBetweenStartEndDate)){
                            consultantBookedDate.addError('Consultant Not Available.');
                            break;
                        }                      
                    }
                }
            }
        }
    }        
}