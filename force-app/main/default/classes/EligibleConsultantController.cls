global with sharing class EligibleConsultantController {

    private Id oppId {get; set;}
    public Opportunity opp {get; set;}
    private Set<Id> setOppLineItem {get; set;}
    public List<EligibleConsultantWrapper> eligibleConsultant {get; set;}
    public String eligibleConsultantJSON {get; set;}
    
    public EligibleConsultantController() {}
    
    public EligibleConsultantController(ApexPages.StandardController controller) {        
        oppId = (Id) controller.getId();
        
        try{
            opp = [SELECT Id, Account.Family_Brand__c,CI_TY__c, Delphi__c, Envision__c, 
                    ISAC__c, SalesPro__c, Opera__c, OnQ__c, Galaxy_LightSpeed__c, 
                    Maestro__c, Fosse__c, Marsha__c, Service_Start_Date__c, Service_End_Date__c,
                    StageName, Consultant_Assigned__c, Remove_Brand_from_Search__c,
                   (SELECT Id, Product2Id, Product2.Name FROM OpportunityLineItems)
                   FROM Opportunity WHERE Id = :oppId];
                   
            //strOppCityState = opp.City_State__c;
            //oppStartDate = opp.Service_Start_Date__c;
            //oppEndDate = opp.Service_End_Date__c;
            
            if(opp.OpportunityLineItems != NULL && !opp.OpportunityLineItems.isEmpty()){
                setOppLineItem = new Set<Id>();
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    setOppLineItem.add(oli.Product2Id);
                }
                
            }
        }catch(Exception e){
            System.debug('Error: ' + e.getMessage());
        }
    }
    
    
    public PageReference getEligibleConsultant() {

        Boolean isConsultantContactConsultant = false;
        Boolean isConsultantStatusActive = false;
        Set<String> setConsultantStatus = new Set<String>{'Profile Pending','Profile Created','Active',
                                                          'Profile Created Internally','Profile Draft Completed',
                                                          'Profile Not Complete','Profile in Review',
                                                          'In Review','ICA Pending','Processing Paperwork'};
                
        List<Contact> listConsultants;
        List<Eligible_Consultant__c> listEligibleConsultant = new List<Eligible_Consultant__c>();
        Map<Id, Eligible_Consultant__c> mapContactIdNEligibleConsultant = new Map<Id, Eligible_Consultant__c>();
        if(opp != NULL && opp.Account != NULL && opp.Account.Family_Brand__c != NULL 
           && opp.Service_Start_Date__c != NULL && opp.Service_End_Date__c != NULL){

            try{

                String strQuery;
                Boolean CI_TY = opp.CI_TY__c;
                Id oppId = opp.Id;
                Boolean Delphi = opp.Delphi__c;
                Boolean Envision = opp.Envision__c;                
                Boolean ISAC = opp.ISAC__c;
                Boolean SalesPro = opp.SalesPro__c;
                Boolean Opera = opp.Opera__c;
                Boolean OnQ = opp.OnQ__c;
                Boolean Galaxy_LightSpeed = opp.Galaxy_LightSpeed__c;
                Boolean Maestro = opp.Maestro__c;
                Boolean Fosse = opp.Fosse__c;
                Boolean Marsha = opp.Marsha__c;
                Date ServiceStartDate = opp.Service_Start_Date__c;
                Date ServiceEndDate = opp.Service_End_Date__c;
                String AccountFamilyBrand = opp.Account.Family_Brand__c;

                strQuery = 'SELECT Id, Name, CI_TY__c, Delphi__c, Envision__c, ISAC__c, SalesPro__c,' +
                           ' Average_Survey_Grade__c, Consultant_Rating__c, '; 
                          
                          /* Check for Family Brand existor not */ 
                if(opp.Remove_Brand_from_Search__c != NULL && opp.Remove_Brand_from_Search__c == false)          
                    strQuery += '(SELECT Id FROM Brands__r ' +
                                'WHERE Family_of_Brands__c = :AccountFamilyBrand ' +
                                'AND Family_of_Brands__c <> NULL LIMIT 1), ';
                          
                            /* Check Service Position matches with Opportunity Line Item */ 
                strQuery += '(SELECT Id FROM Service_Position__r ' +
                            'WHERE Service_Position__c IN :setOppLineItem AND Service_Position__c <> NULL LIMIT 1), ' +
                          
                            /* Check for Consultant availablity related to Consultant Contact(Opportunity) */
                            '(SELECT Service_Start_Date__c,Service_End_Date__c FROM Consultant_Contact__r ' +
                            'WHERE (Service_Start_Date__c <> null AND Service_End_Date__c <> null) ' +
                            'AND ((Service_Start_Date__c <= :ServiceStartDate ' +
                                    'AND Service_End_Date__c >= :ServiceStartDate) ' +
                                'OR ' +
                                '(Service_Start_Date__c <= :ServiceEndDate ' +
                                    'AND Service_End_Date__c >= :ServiceEndDate)) ' +
                            'LIMIT 1), ' +
                          
                            /* Check for Consultant availablity related to Block Out Dates */                                                        
                            '(SELECT Not_Available_Start_Date__c, Not_Available_End_Date__c ' +
                            'FROM Consultant_Block_Out_Dates__r ' +
                            'WHERE (Not_Available_Start_Date__c <> null AND Not_Available_End_Date__c <> null) ' +
                            'AND ((Not_Available_Start_Date__c <= :ServiceStartDate ' +
                                    'AND Not_Available_End_Date__c >= :ServiceStartDate) ' +
                                'OR ' +
                    			'(Not_Available_Start_Date__c >= :ServiceStartDate ' +
                                    'AND Not_Available_End_Date__c <= :ServiceEndDate) ' +
                                'OR ' +
                                '(Not_Available_Start_Date__c <= :ServiceEndDate ' +
                                    'AND Not_Available_End_Date__c >= :ServiceEndDate)) ' +
                            'LIMIT 1), ' +
                           
                            /* Eligible Consultant record related to current Opportunity record */
                            '(SELECT Interested__c, Status__c ' +
                            'FROM Eligible_Consultants__r ' +
                            'WHERE Opportunity__c <> :oppId ' +
                            'AND (Status__c IN (\'Eligible\', \'Selected\')) ' +
                            'AND (Opportunity__r.Service_Start_Date__c <> null AND Opportunity__r.Service_End_Date__c <> null) ' +
                            'AND ((Opportunity__r.Service_Start_Date__c <= :ServiceStartDate ' +
                                  'AND Opportunity__r.Service_End_Date__c >= :ServiceStartDate) ' +
                                'OR ' +
                              '(Opportunity__r.Service_End_Date__c <= :ServiceEndDate ' +
                                  'AND Opportunity__r.Service_End_Date__c >= :ServiceEndDate)) ' +
                            'LIMIT 1) ' +                                  
                            'FROM Contact c ' +
                            'WHERE RecordType.Name = \'Consultants\' ' +
                            'AND Consultant_Status__c IN :setConsultantStatus ' +
                            'AND Task_Force__c = True '+
                            'AND (CI_TY__c = :CI_TY OR Delphi__c = :Delphi ' +
                                'OR Envision__c = :Envision OR ISAC__c = :ISAC ' +
                                'OR SalesPro__c = :SalesPro OR Opera__c = :Opera ' +
                                'OR OnQ__c = :OnQ OR Galaxy_LightSpeed__c = :Galaxy_LightSpeed ' +
                                'OR Maestro__c = :Maestro OR Fosse__c = :Fosse '  +
                                'OR Marsha__c = :Marsha)'; 
                
                System.debug('opp : ' + opp);
                System.debug('strQuery : ' + strQuery);
                listConsultants = Database.query(strQuery);
                System.debug('listConsultants'+listConsultants);
                                      
                listEligibleConsultant = new List<Eligible_Consultant__c >([SELECT Id, Interested__c, Status__c, Consultant__c 
                                                              FROM Eligible_Consultant__c
                                                              WHERE Consultant__c IN :listConsultants
                                                              AND Opportunity__c = :opp.Id
                                                              ORDER BY LastModifiedDate DESC]); 
               for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultant ){
                   if(!mapContactIdNEligibleConsultant.containsKey(eligibleConsultant.Consultant__c))
                       mapContactIdNEligibleConsultant.put(eligibleConsultant.Consultant__c, eligibleConsultant);
               }
            }catch(Exception ex){
                System.debug('Error: ' + ex.getStackTraceString());
            }       
        }
        
        eligibleConsultant = new List<EligibleConsultantWrapper>();
        if(listConsultants != NULL && !listConsultants.isEmpty()){           
            for(Contact consultant : listConsultants){
                
                if(((!consultant.Brands__r.isEmpty() && opp.Remove_Brand_from_Search__c == false) || opp.Remove_Brand_from_Search__c == true) 
                   && !consultant.Service_Position__r.isEmpty()
                   && consultant.Consultant_Contact__r.isEmpty()
                   && consultant.Consultant_Block_Out_Dates__r.isEmpty()
                   && consultant.Eligible_Consultants__r.isEmpty()
                  )                   
                    if(mapContactIdNEligibleConsultant.containsKey(consultant.Id)){
                        eligibleConsultant.add(new EligibleConsultantWrapper(consultant, mapContactIdNEligibleConsultant.get(consultant.Id)));
                    }
                    else{
                        eligibleConsultant.add(new EligibleConsultantWrapper(consultant));
                    }
            }
        }    
        
        if(eligibleConsultant != NULL && eligibleConsultant.size() > 0 ){
            eligibleConsultantJSON = String.valueOf(JSON.serializePretty(eligibleConsultant)).replaceAll('\\s+',' ');
        }                        
        System.debug('eligibleConsultantJSON : ' + eligibleConsultantJSON);
        System.debug('eligibleConsultant : ' + eligibleConsultant);
        return null;
    } 
    
    @RemoteAction
    global static String sendSMS(List<String> listConsultantIds, String strOppId, String setEligibleConsultantIds){       
        System.debug('listConsultantIds ::: ' + listConsultantIds);

        if(listConsultantIds != NULL && !listConsultantIds.isEmpty()){            
            return sendTwilioSMS(listConsultantIds, strOppId, setEligibleConsultantIds);     
        }
        return 'Error - Message sending failed!!!';
    }
    
     @RemoteAction
     global static String createEligibleConsultants(List<String> listConsultantIds, String strOppId){
        
        List<Eligible_Consultant__c> listEligibleConsultants = new List<Eligible_Consultant__c>();
        try{
            Opportunity opp = [SELECT Account.Family_Brand__c FROM Opportunity WHERE Id = :strOppId];
            if(opp != NULL){
                for(String strConsultantId : listConsultantIds){
                    listEligibleConsultants.add(new Eligible_Consultant__c(Consultant__c = strConsultantId,
                                                                            Opportunity__c = strOppId,
                                                                            Family_of_Brands__c = opp.Account.Family_Brand__c));
                }
                
                if(listEligibleConsultants != NULL && !listEligibleConsultants.isEmpty()){
                    insert listEligibleConsultants;
                }
            }
        }catch(Exception ex){
            System.debug('Error: ' + ex.getLineNumber() + ' -- ' + ex.getMessage());
            return 'Error: ' + ex.getMessage();
        }
        Set<Id> setEligibleConsultantIds = new Set<Id>();      
        for(Eligible_Consultant__c eligibleConsultant : listEligibleConsultants){
            setEligibleConsultantIds.add(eligibleConsultant.Id);
        }  
         
        return String.valueOf(setEligibleConsultantIds);
    }
    
    private static String sendTwilioSMS(List<String> listConsultantIds, String strOppId, String setEligibleConsultantIds){
    
        //List<Eligible_Consultant__c> listEligibleConsultant = [SELECT Id FROM Eligible_Consultant__c WHERE Id IN :setEligibleConsultantIds];
    
        List<Contact> listSelectedConsultant = [SELECT Phone FROM Contact WHERE Id IN :listConsultantIds];
        
        if(listSelectedConsultant != NULL && !listSelectedConsultant.isEmpty()){
            List<String> listConsultantPhoneNumbers = new List<String>();
            for(Contact consultant : listSelectedConsultant ){
                if(consultant.Phone != NULL){
                    listConsultantPhoneNumbers.add(consultant.Phone);
                }
            }
            System.debug('listConsultantPhoneNumbers : ' + listConsultantPhoneNumbers);

            if(listConsultantPhoneNumbers != NULL && !listConsultantPhoneNumbers.isEmpty()){
                Opportunity opp;    
                try{
                    opp = [SELECT Id, City_State__c, Service_Start_Date__c, Service_End_Date__c,
                            Account.Family_Brand__c,
                            (SELECT Product2.Name FROM OpportunityLineItems)                               
                           FROM Opportunity WHERE Id = :strOppId];
                           
                    //strOppCityState = opp.City_State__c;
                    //oppStartDate = opp.Service_Start_Date__c;
                    //oppEndDate = opp.Service_End_Date__c;                        
                    
                }catch(Exception ex){
                    System.debug('Error: ' + ex.getStackTraceString());
                    return ('Error: ' + ex.getStackTraceString());
                }
            
                // Find your Account Sid and Auth Token at twilio.com/user/account 
                TwilioConfig__c auth = TwilioConfig__c.getValues('Live');
                if(auth != NULL && auth.AccountSid__c != NULL && auth.AuthToken__c != NULL && auth.TwilioNumber__c != NULL){
                    String ACCOUNT_SID= auth.AccountSid__c ; 
                    String AUTH_TOKEN= auth.AuthToken__c; 

                    TwilioRestClient client = new TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN);
                    Map<String,String> properties;
                    TwilioMessage message;
                    
                    try{                        
                        for(String conultantPhoneNumber : listConsultantPhoneNumbers){
                            properties = new Map<String,String> {'To'   => conultantPhoneNumber,
                                                                'From' => auth.TwilioNumber__c,
                                                                'Body' => 'TF Opening: "' + (opp.OpportunityLineItems.size() > 0? opp.OpportunityLineItems[0].Product2.Name:'----') 
                                                                           + '" in ' + opp.City_State__c + ' for a ' + opp.Account.Family_Brand__c + ' brand property from ' 
                                                                           + Date.valueOf(opp.Service_Start_Date__c).format() + ' - ' + Date.valueOf(opp.Service_End_Date__c).format() 
                                                                           + '.  Please reply: YES or NO. Carver Hotel Group'};
                                                                //'Body' => 'Hello !' };
                            message = client.getAccount().getMessages().create(properties);
                            System.debug('message ::: ' + message.getSid());
                        }
                        System.debug('message ::: ' + message.getSid());
                    }catch(TwilioRestException twilioEx){
                        System.debug('Error: ' + twilioEx.getMessage());
                       /* if(!listEligibleConsultant.isEmpty()){
                            delete listEligibleConsultant;
                        }      */                      
                        return ('Error - ' + twilioEx.getMessage());
                    }/*catch(Exception ex){
                        System.debug('Error: ' + ex.getMessage());
                        return ('Error: ' + ex.getMessage());
                    }*/
                    return 'SMS Sent Successfully!!!';//String.valueOf(message.getSid());
                }
                else{
                   /* if(!listEligibleConsultant.isEmpty()){
                        delete listEligibleConsultant;
                    } */ 
                    return 'Error - Twilio Account SID or Auth Token missing!!!';                   
                }
                
            }
            else{
                /*if(!listEligibleConsultant.isEmpty()){
                    delete listEligibleConsultant;
                } */ 
                return 'Error - Consultant Phone number is missing!!!';
            }
        }   
        /*if(!listEligibleConsultant.isEmpty()){
            delete listEligibleConsultant;
        }  */
        return 'Error - Message sending failed!!!';
    }  
}