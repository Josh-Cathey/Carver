/*
 * @ Purpose : Controller for Target List Page.
 * @ Created Date : 26-02-2018. 
*/
global class TargetListController {
    
    public Id oppId {get; set;}
    public Opportunity opp {get; set;}
    public List<String> setOppLineItem {get; set;}
    
    public TargetListController(ApexPages.StandardController controller) {    
        
        oppId = (Id) controller.getId();
        
        if(String.isNotBlank(oppId)){
            
            try{
                opp = [SELECT Id, Name, Account.Family_Brand__c, StageName, Family_of_Hotel_Brands__c, 
                              State__c,of_Rooms__c,Salary_Low_Range_Factor__c, Salary_High_Range_Factor__c,
                              (SELECT Id, Product2Id, Product2.Name FROM OpportunityLineItems)
                       FROM Opportunity
                       WHERE Id = :oppId 
                       AND RecordType.Name =: 'Search'
                       //AND StageName =: 'Creating Target List'
                      ];
                
                if(opp.OpportunityLineItems != NULL && !opp.OpportunityLineItems.isEmpty()){
                    setOppLineItem = new List<String>();
                    
                    for(OpportunityLineItem oli : opp.OpportunityLineItems){
                        setOppLineItem.add(String.valueOf(oli.Product2Id));
                    }
                }
            }catch(Exception e){
                System.debug('Error: ' + e.getMessage());
            }
        }
    }
    
    /*
     * @Purpose : Method to get Contact record with respect to filters which are as follow:
                    1.Contacts Record Type = 'Consultant'.
                    2.Contacts   Permanent_Placement__c = TRUE.
                    3.Contacts State__c  = Opportunity.State__c.
                    4.Contacts   “# of Rooms” / “of_Rooms__c” >= Opportunity.“# of Rooms” / “of_Rooms__c”.
                    5.Contacts related Brands = Opportunity.Brands__c ( We are now using Contact related Brands object picklist field Family_of_Brands__c and match with Opportunity picklist field – Family_of_Hotel_Brands__c).
                    6.Contact related Service Position = Opportunity related OpportunityLine Items. 
    
     * @Parameters : String oppRecordStr, String setOppLineItemStr, String filterString.
     * @Return Type : Response.
    */
    @RemoteAction
    global static Response getContactRecords(String oppRecordStr, String setOppLineItemStr, String filterString){
        String strQuery;
        
        List<Contact> listConsultants;
        List<TargetListWrapper.contactDTO> TargetListConsultants = new List<TargetListWrapper.contactDTO>();
        List<String> setOppLineItem = new List<String>();
        
        TargetListWrapper.filterDTO filterRec;
        TargetListWrapper.OpportunityDTO oppRec; 
        
        Set<String> setConsultantStatus = new Set<String>{'Not Active- Not Eligible for Re-Contract','Not Active - Permanently Placed'};       
        
        
        if(String.isNotBlank(oppRecordStr) && String.isNotBlank(filterString)) {
            
            try {
                filterRec = (TargetListWrapper.filterDTO) JSON.deserialize(filterString, TargetListWrapper.filterDTO.Class);
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);     
            }
            
            try {
                oppRec = (TargetListWrapper.OpportunityDTO) JSON.deserialize(oppRecordStr, TargetListWrapper.OpportunityDTO.Class);
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);            
            }  
            
            if(oppRec != null) {
                
                String oppFamilyBrand = oppRec.familyOfHotelBrand;
                String oppState = oppRec.state;
                String oppId = oppRec.recordId;
                
                Integer oppNoRoom = oppRec.noOfRoom;
                
                Decimal salaryLowRangeFactorVal = String.isnotBlank(oppRec.salaryLowRangeFactor) ? Decimal.valueOf(oppRec.salaryLowRangeFactor) :  0.0;
                Decimal salaryHighRangeFactorVal = String.isnotBlank(oppRec.salaryHighRangeFactor) ? Decimal.valueOf(oppRec.salaryHighRangeFactor) : 0.0; 
                
                setOppLineItem = getOppLineItemProducts(oppRec.recordId);
                
                strQuery = 'SELECT Id, Name, Current_Salary__c, of_Rooms__c, Will_Relocate__c, US_Citizen__c, Union_Experience__c, MailingCity , MailingState ';
                
                strQuery += ' , (SELECT Id FROM Target_Lists__r' +
                                '  WHERE Opportunity__c =: oppId AND Opportunity__c <> NULL LIMIT 1) ';
                
                // Check for Family Brand existor not 
                if(String.isNotBlank(oppFamilyBrand) && filterRec.familyOfBrandsFilters == false) {          
                    strQuery += ' , (SELECT Id FROM Brands__r ' +
                                '  WHERE Family_of_Brands__c = :oppFamilyBrand ' +
                                '  AND Family_of_Brands__c <> NULL LIMIT 1) ';
                }
                
               
                // Check Service Position matches with Opportunity Line Item 
                if(setOppLineItem.Size() > 0) {                
                    strQuery += ' , (SELECT Id FROM Service_Position__r' +
                                '  WHERE Service_Position__c IN: setOppLineItem AND Service_Position__c <> NULL LIMIT 1) ';
                }
                
                strQuery += ' FROM Contact c ' +
                            ' WHERE RecordType.Name = \'Consultants\' ' +
                            ' AND Permanent_Placement__c = True '+
                            ' AND Consultant_Status__c NOT IN: setConsultantStatus ';
                
                if(filterRec.StateFilter == false) {         
                    strQuery += 'AND State__c =: oppState ';
                } 
                
                if(filterRec.desiredSalary == false && salaryHighRangeFactorVal != 0.0) {         
                    strQuery += 'AND  (Current_Salary__c >= : salaryLowRangeFactorVal AND Current_Salary__c <= : salaryHighRangeFactorVal) ';
                } 
                
                if(filterRec.noOfRoomsFilter == false) {         
                    strQuery += 'AND of_Rooms__c >=: oppNoRoom';
                }    
                
                system.debug('strQuery :::' + strQuery + ':::oppNoRoom:::'  + oppNoRoom + ':::oppState  ::' + oppState );

                try {
                    listConsultants = Database.query(strQuery);
                }catch(Exception ex) {
                    System.debug('Exception is '+ ex.getMessage());
                    return new Response(false, 'Error :' + ex.getMessage(), (Object)null);  
                }
                
                if(listConsultants != NULL && !listConsultants.isEmpty()) {                
                    system.debug('listConsultants ::::' + Json.serialize(listConsultants));
                    
                    for(Contact consultant : listConsultants) {                     
                         
                        Boolean isTargetListCreated = consultant.Target_Lists__r.isEmpty() ? false: true;
                                      
                        if((filterRec.familyOfBrandsFilters == false && !consultant.Brands__r.isEmpty())  
                            && !consultant.Service_Position__r.isEmpty()) {
                            TargetListConsultants.add(new TargetListWrapper.contactDTO(consultant, isTargetListCreated));
                        }else if(filterRec.familyOfBrandsFilters == true && !consultant.Service_Position__r.isEmpty()){
                            TargetListConsultants.add(new TargetListWrapper.contactDTO(consultant, isTargetListCreated));    
                        }
                    }
                }
                
                if(TargetListConsultants != NULL && !TargetListConsultants.isEmpty()) {
                    return new Response(true, 'Success in getting Contacts', TargetListConsultants);
                }else{
                    return new Response(false, 'No Candidate present for given filters', (Object)null);    
                }
            }    
        }
        
        return new Response(false, 'Error in Filter or Object', (Object)null);  
        
    } 
    
    /*
     *@ Purpose: Method to get opportunityLineItems Products with respect to given opportunity Id.
     *@ Parameter: String oppId.
     *@ Return: List<String>.
    */
    private static List<String> getOppLineItemProducts(String oppId) {
        List<String> productIdList = new List<String>();
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        
        if(String.isNotBlank(oppId)) {
            
            try {
                oppLineItemList = [SELECT Id, OpportunityId, Product2Id  
                                   FROM OpportunityLineItem 
                                   WHERE OpportunityId  =: oppId];
            }catch(Exception ex) {
                System.debug('Exception is '+ ex.getMessage());
            } 
            
            if(oppLineItemList != NULL && !oppLineItemList.isEmpty()){
                
                for(OpportunityLineItem oppLineItemRec : oppLineItemList){
                    
                    if(oppLineItemRec.Product2Id != null){
                        productIdList.add(String.valueOf(oppLineItemRec.Product2Id));
                    } 
                }   
            }
                                             
        }
        
        return productIdList;
    }
    
    /*
     * @Purpose : Method to Create Traget List Object with respect to opprotunity and Selected Contacts.
     * @Parameters : String oppRecordStr, List<TargetListWrapper> TargetListWrapperList.
     * @Return Type : Response.
    */
    @RemoteAction
    global static Response createTargetList(String oppRecordStr, List<TargetListWrapper.contactDTO> TargetListWrapperList){
        
        List<Target_List__c> newTargetList = new List<Target_List__c>();
        TargetListWrapper.OpportunityDTO oppRec;
        
        if(String.isNotBlank(oppRecordStr) && (TargetListWrapperList != NULL && !TargetListWrapperList.isEmpty())) {
            
            try{
                oppRec = (TargetListWrapper.OpportunityDTO) JSON.deserialize(oppRecordStr, TargetListWrapper.OpportunityDTO.Class);
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);            
            }
            
            for(TargetListWrapper.contactDTO contactRec : TargetListWrapperList) {
                
                Target_List__c targetListRec = new Target_List__c();
                targetListRec.Candidate__c = contactRec.recordId ;
                targetListRec.Opportunity__c = oppRec.recordId;
                newTargetList.add(targetListRec); 
            }
            
            if(newTargetList != NULL && !newTargetList.isEmpty()){
                
                try {
                    insert newTargetList; 
                    return new Response(true, 'Success in creating target List records', newTargetList);   
                }catch(Exception ex) {
                    return new Response(false, 'Error :' + ex.getMessage(), (Object)null);  
                }
                
            }
        }
        return new Response(false, 'Missing Paratmerters', (Object)null);  
    }
    
    /*
     * @Purpose : Method to create Account of record type Consultant Account.
     * @Parameters : String accountRecString.
     * @Return Type : Response.
    */
    @RemoteAction
    global static Response createAccountRecord(String accountRecString){
        
        if(String.isNotBlank(accountRecString)){
          
            accountDTO accountDTORec;
            Id accRecordTypeId;
            
            try{
                accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Consultant Account').getRecordTypeId();
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);
            }   
             
            try{
                accountDTORec = (accountDTO)JSON.deserialize(accountRecString, accountDTO.Class);
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);     
            }
            
            if(accountDTORec != null && accRecordTypeId != null) {
            
                Account accountRec = new Account();
                
                accountRec.Name = accountDTORec.firstName + ' '+ accountDTORec.lastName + ' - Consultant Account '; 
                accountRec.RecordTypeId = accRecordTypeId;
                
                try{
                    insert accountRec;
                    return new Response(true, 'Success in creating Account Record', accountRec); 
                }catch(Exception ex) {
                    return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);  
                }
            }
            
        }
        return new Response(false, 'No parameter', (Object)null);  
    }
    
    /*
     * @Purpose : Method to create Contact of record type Consultant.
     * @Parameters : String contactRecString, Account accountRec.
     * @Return Type : Response.
    */
    @RemoteAction
    global static Response createContactRecord(String contactRecString, Account accountRec){
        
        if(String.isNotBlank(contactRecString) && accountRec != null){  
        
            contactDTO contactDTORec;
            Id contactRecordTypeId;             
            
            try{
                contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Consultants').getRecordTypeId();
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);
            } 
              
            try{
                contactDTORec = (contactDTO)JSON.deserialize(contactRecString, contactDTO.Class);
            }catch(Exception ex){
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);     
            }
            
            if(contactDTORec != null && contactRecordTypeId != null) {
            
                Contact contactRec = new Contact();
                
                contactRec.FirstName = String.isNotBlank(contactDTORec.firstName) ? contactDTORec.firstName: '';
                contactRec.LastName = String.isNotBlank(contactDTORec.LastName) ? contactDTORec.LastName: '';
                
                contactRec.Current_Position_Title__c = String.isNotBlank(contactDTORec.currentPositionTitle) ? contactDTORec.currentPositionTitle: '';
                contactRec.Email = String.isNotBlank(contactDTORec.Email) ? contactDTORec.Email : '';
                
                contactRec.Phone = String.isNotBlank(contactDTORec.Phone) ? contactDTORec.Phone : '';
                contactRec.MailingCity = String.isNotBlank(contactDTORec.City) ? contactDTORec.city : '';
                
                contactRec.MailingState = String.isNotBlank(contactDTORec.state) ? contactDTORec.state: '';
                contactRec.Years_of_Experience__c = String.isNotBlank(contactDTORec.yearsOfExperience) ? Decimal.valueOf(contactDTORec.yearsOfExperience): 0 ;
                
                contactRec.Currently_Employed__c = contactDTORec.currentlyEmployed;
                contactRec.Current_Salary__c = String.isNotBlank(contactDTORec.currentSalary) ? Decimal.valueOf(contactDTORec.currentSalary) : 0.0 ;
    
                contactRec.Recruiting_Source__c = String.isNotBlank(contactDTORec.recruitingSource) ? contactDTORec.recruitingSource : '' ;
                contactRec.RecordTypeId = contactRecordTypeId;
                
                contactRec.Consultant_Status__c = 'Newly Identified';
                contactRec.AccountId = accountRec.Id;
                
                contactRec.Permanent_Placement__c = true;
                
                try{
                    insert contactRec;
                    return new Response(true, 'Success in creating Contact record', contactRec); 
                }catch(Exception ex) {
                    return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);  
                }
            }
            
        }
        return new Response(false, 'No parameter', (Object)null);  
    }
    
    /*
     * @Purpose : Method to create Traget List record
     * @Parameters : String contactRecId, String opportunityRecId.
     * @Return Type : Response.
    */
    @RemoteAction
    global static Response createTargetListRecord(String contactRecId, String opportunityRecId){
        
        if(String.isNotBlank(contactRecId) && String.isNotBlank(opportunityRecId)){
            
            Target_List__c targetListRec = new Target_List__c();
            
            targetListRec.Candidate__c = contactRecId;
            targetListRec.Opportunity__c = opportunityRecId;
            
            try{
                insert targetListRec;
                return new Response(true, 'Success in creating Target List Record', targetListRec); 
            }catch(Exception ex) {
                return new Response(false, 'Error :'+ ex.getMessage() , (Object)null);  
            }
            
        }
        
        return new Response(false, 'Error : Contact or Opportunity is missing', (Object)null);  
    }
    
     /*
     * @Purpose : Method to get picklist Value.
     * @Parameters : void.
     * @Return Type : List<String>.
    */
    @RemoteAction
    global static List<String> getPickListValuesIntoList(){
    
       List<String> pickListValuesList= new List<String>();
       
        Schema.DescribeFieldResult fieldResult = Contact.Recruiting_Source__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    global class accountDTO {
    
        public String firstName;
        public String lastName;
        
        global accountDTO(){}
    }
    
    global class contactDTO {
    
        public String firstName;
        public String LastName;
        
        public String currentPositionTitle;        
        public String Email;
        
        public String Phone;        
        public String city;
        
        public String state;
        public String yearsOfExperience;
        
        public Boolean currentlyEmployed;
        public String currentSalary;        
        
        public String recruitingSource;
        
        global contactDTO(){}
    }
    
    /*global class Response{
        
        global String message;
        global Boolean isSuccess;        
        global Object record;
        
        global Response(Boolean isSuccess, String message, Object record){
            
            this.message = message;
            this.isSuccess = isSuccess;
            this.record = record;
        }
    }*/
    
    global class Response{
        
        global String message;
        global Boolean isSuccess;
        global List<Object> recordList;
        global Object record;
        
        global Response(Boolean isSuccess, String message, Object record){
            
            this.message = message;
            this.isSuccess = isSuccess;
            this.record = record;
        }
        
        global Response(Boolean isSuccess, String message, List<Object> recordList){
            
            this.message = message;
            this.isSuccess = isSuccess;
            this.recordList = recordList;
        }
    } 
}