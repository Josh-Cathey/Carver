/**********************************************************************************************************
    @Developer    : Sagar
    @Purpose      : To Clone the Opportunity 
    @Created Date : 21-March-2016   

************************************************************************************************************/

global class OpportunityHelper {
   /**
    @Purpose: To colone the existing opportunity records 
   */
   webservice static String cloneOpportunity(String opportunityId ){
       String strResult;
       List<OpportunityLineItem> listOfOppLineItem;
       List<OpportunityLineItem> listOfNewOppLineItem;
       
       try{
           if(String.isNotBlank(opportunityId)){
                // Get all fields of Opportunity object. 
                String strSoql = getCreatableFieldsSOQL('Opportunity',('id= \''+opportunityId)+'\'');
                System.debug('soql::'+strSoql);
                // Fetch field value of Opportunity 
                Opportunity opp = (Opportunity)Database.query(strSoql); 
                // Clone record 
                Opportunity newOpportunity = opp.clone(False, True);
               
                newOpportunity.Master_Opportunity__c = (opp.Master_Opportunity__c != NULL ? opp.Master_Opportunity__c : opportunityId);  
                newOpportunity.Name = 'EXT ' + newOpportunity.Name;
                newOpportunity.StageName = 'Tentative';
                newOpportunity.Service_End_Date__c = null;
                newOpportunity.Service_Start_Date__c = null;
                newOpportunity.Airfare_Needed__c = null; 
                newOpportunity.Booked_Travel_Date__c = null;
                newOpportunity.CO_Source_Opportunity__c = null; 
                newOpportunity.Extend__c = null;
                newOpportunity.LeadSource = null; 
                newOpportunity.NextStep = null; 
                newOpportunity.State_for_Contract__c = null; 
                newOpportunity.Trip_Rotation__c = null; 
                newOpportunity.Completed__c = false;
                newOpportunity.One_Way_or_Round_Trip__c = null; 
                newOpportunity.Time_Needed_on_Property__c = null; 
                newOpportunity.Time_Allowed_to_Leave_Property__c = null; 
                newOpportunity.Ground_Transportation__c = null; 
                newOpportunity.Travel_Special_Notes__c = null; 
                newOpportunity.Thumbs_Up_or_Down__c = null; 
                newOpportunity.Is_Master__c = false; 
                Insert newOpportunity;
                
                // Clone the Opportunity Line Items  
                if(newOpportunity != null){
                    listOfOppLineItem = new List<OpportunityLineItem>();
                    listOfNewOppLineItem  = new List<OpportunityLineItem>();
                    // Get all fields of Opportunity object. 
                    strSoql = getCreatableFieldsSOQL('OpportunityLineItem',('OpportunityId= \''+opportunityId)+'\'');
                    if(strSoql.containsIgnoreCase('TotalPrice,')){
                        strSoql = strSoql.remove('TotalPrice,');
                    }
                    System.debug('soql::'+strSoql);
                    
                    // Fetch field value of Opportunity 
                    listOfOppLineItem = (List<OpportunityLineItem>)Database.query(strSoql);
                    if(!listOfOppLineItem.isEmpty()){
                        for(OpportunityLineItem opplineItem: listOfOppLineItem){
                            // Clone record 
                            OpportunityLineItem clonedOppline = opplineItem.clone(False, True);
                            clonedOppline.OpportunityId = newOpportunity.id;
                            listOfNewOppLineItem.add(clonedOppline);
                        }
                        Insert listOfNewOppLineItem;
                    }
                }
                strResult = 'successful'+newOpportunity.id;
           }else{
              strResult = 'Opportunity not has been created.';
           }    
       } Catch(Exception e){
           System.debug('The following exception has occurred  ' + e.getMessage() +
                         'At line number :' + e.getLineNumber() + ' Error ' + e.getStackTraceString());
            strResult = 'The following exception has occurred ' + e.getMessage();    
       }
       
       return strResult;
    }
    
    /*
     @Purposae: Returns a dynamic SOQL statement for the whole object, includes only creatable fields 
     since we will be inserting a cloned result of this query. 
     @Parameter : Object Name ,Id    
    */
    webService static string getCreatableFieldsSOQL(String objectName, String whereClause){         
        String selects = '';
        
        if (whereClause == null || whereClause == ''){ 
            return null; 
        }
        
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){          // loop through all field tokens (ft)
            
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){                    // field is creatable                    
                    selectFields.add(fd.getName());
                }
            }
        }
        
        if (!selectFields.isEmpty()){
        
            for (string s:selectFields){            
                selects += s + ',';
            }
            if (selects.endsWith(',')){            
                selects = selects.substring(0,selects.lastIndexOf(','));
            }             
        }         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;         
    }
}