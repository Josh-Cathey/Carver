global without sharing class CalendarController {
    
    public CalendarController() {}
    public CalendarController(ApexPages.StandardController controller) {}
  
    @RemoteAction
    global static List<EventWrapper> getConsultantDates(Id consultantId){
        List<EventWrapper> listConsultantDates = new List<EventWrapper>();
        
        listConsultantDates.addAll(getConsultantBookedDates(consultantId));
        listConsultantDates.addAll(getConsultantBlockOutDates(consultantId));
        
        return listConsultantDates;
    }

    private static List<EventWrapper> getConsultantBookedDates(Id consultantId){
        List<EventWrapper> listBookedDetails = new List<EventWrapper>();

        List<Eligible_Consultant__c> listEligibleConsutlants =  new List<Eligible_Consultant__c>();
        listEligibleConsutlants = [SELECT Id, Opportunity__c 
                                  FROM Eligible_Consultant__c 
                                  WHERE Consultant__c = :consultantId
                                  AND
                                  (Interested__c <> 'No' AND (Status__c = 'Eligible'))
                                  AND Opportunity__r.Consultant_Assigned__c = ''
                                  AND Opportunity__r.StageName <> 'Closed Lost'
                                  ];

        Set<Id> setOpportunitiesIds;
        if(listEligibleConsutlants != NULL && !listEligibleConsutlants.isEmpty()){
            setOpportunitiesIds = new Set<Id>();
            for(Eligible_Consultant__c eligibleConsultant : listEligibleConsutlants){
                if(eligibleConsultant.Opportunity__c != NULL)
                    setOpportunitiesIds.add(eligibleConsultant.Opportunity__c);
            } 
        }
        System.debug('setOpportunitiesIds : ' + setOpportunitiesIds);
        List<Opportunity> listOpportunities = new List<Opportunity>();
        //if(setOpportunitiesIds != NULL && !setOpportunitiesIds.isEmpty())
            listOpportunities = [SELECT Consultant_Assigned__c, Service_Start_Date__c, Service_End_Date__c, Account_Name__c
                                FROM Opportunity
                                WHERE (Id IN :setOpportunitiesIds
                                OR Consultant_Assigned__c = :consultantId)
                                AND StageName <> 'Closed Lost'];
        
        /*if(!listOpportunities.isEmpty()){
            listBookedDetails = new List<EventWrapper>();
        }*/
        System.debug('listOpportunities : ' + listOpportunities);
        for(Opportunity oppRecord : listOpportunities){
            if(oppRecord.Service_Start_Date__c != NULL && oppRecord.Service_End_Date__c != NULL){
            listBookedDetails.add(new EventWrapper(oppRecord.Account_Name__c,
                                                   oppRecord.Service_Start_Date__c,
                                                   oppRecord.Service_End_Date__c));
            }
        }
        
        System.debug('listBookedDetails : ' + listBookedDetails);        
        //listBookedDetails = new List<EventWrapper>();
        return listBookedDetails;
    }    
   
    private static List<EventWrapper> getConsultantBlockOutDates(Id consultantId){
        List<EventWrapper> listBlockOutDetails = new List<EventWrapper>();
            
        List<Consultant_Block_Out_Dates__c > listBlockOutDates = new List<Consultant_Block_Out_Dates__c>();
        listBlockOutDates = [SELECT Consultant_Contact__c, Not_Available_Start_Date__c, Not_Available_End_Date__c, Not_Available_Details__c
                             FROM Consultant_Block_Out_Dates__c  WHERE Consultant_Contact__c = :consultantId];
        
        /*if(!listBlockOutDates.isEmpty()){
            listBlockOutDetails = new List<EventWrapper>();
        }*/
        
        for(Consultant_Block_Out_Dates__c blockOutRecord : listBlockOutDates){
            if(blockOutRecord.Not_Available_Start_Date__c != NULL && blockOutRecord.Not_Available_End_Date__c != NULL){
                listBlockOutDetails.add(new EventWrapper('Consultant Not Available',
                                                         blockOutRecord.Not_Available_Start_Date__c,
                                                         blockOutRecord.Not_Available_End_Date__c));
            }
        }
        return listBlockOutDetails;
    }
    
    @RemoteAction
    global static String createConsultantBlockOutDates(Id consultantId,String startDate, String endDate,String blockOutDetails){
        Consultant_Block_Out_Dates__c bockOutDetails = new Consultant_Block_Out_Dates__c();
        bockOutDetails.Consultant_Contact__c = consultantId;
        if(startDate != NULL){
            bockOutDetails.Not_Available_Start_Date__c = Date.valueOf(startDate);
        }
        if(endDate != NULL){
            bockOutDetails.Not_Available_End_Date__c = Date.valueOf(endDate);
        }
        bockOutDetails.Not_Available_Details__c = blockOutDetails;
        
        try{
            insert bockOutDetails;            
        } catch(Exception ex){
            System.debug('Error - ' + ex.getMessage());
            if(ex.getMessage().contains('Block Out Dates are already blocked')){
                return ('Error-Block Out Dates are already blocked');
            } else if(ex.getMessage().contains('Consultant Not Available')){
                return ('Error-Consultant Not Available');
            }
            return ('Error-' + ex.getMessage());
        }
        if(bockOutDetails != NULL && bockOutDetails.Id != NULL){
            return 'Block Out Dates are successfully reserved.';
        }
        return '';
    }  
 
    global class EventWrapper{
        public String title {get; set;}
        public Datetime start {get; set;}
        public Datetime endDate {get; set;}
        
        public EventWrapper(String title, Date start, Date endDate){
            this.title = title;
            System.debug('Start : ' + start);
            System.debug('End : ' + endDate);
            
            if(start != null)            
                this.start = getLocalGMT(start);
            else
                this.start = start;
                
            if(endDate != null)    
                this.endDate = getLocalGMT(endDate).addDays(1);
            else
                this.endDate = endDate;            
            
            System.debug('this.Start : ' + this.start);
            System.debug('this.End : ' + this.endDate);
        }
        public Datetime getLocalGMT(Datetime gmtDateTime){    
            Date d = gmtDateTime.dateGmt();
            Time t = gmtDateTime.timeGmt();
            return Datetime.newInstance(d,t);
        }
    }  
}