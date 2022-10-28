/**
  * @Description   : Roll up sum of Potential Revenue of Lead records to account field LeadPotentialRevenue
                     when below criteria is satisfied:
                      1. Lead Record Type: “SX – RFPs”
                      2. Converted = False 
                      3. “Lead Status” field = New Bid, Bid Sent – Waiting on Response, Bid Sent – No Response.
  * @Created By    : 
  * @Date          : 27 April 2017
  * @Invoked From  : Lead Trigger
 */

public class LeadPotentialRevenueRollup {
    
    /*
    @   Description : calculating and updating the all Lead Potential Revenue sum to Account Lead Potential Revenue
    */
    public static void updateLeadPotentialRevenueTotal( Set<Id> newSXPropertyAccounts ) {
    
        //-- List of Accounts(SX_Property_Account__c) objects update    
        List<Account> accountsToUpdate = new List<Account>();
        //System.debug(' newSXPropertyAccounts : ' + newSXPropertyAccounts );
        //System.debug(' getLeadRecordTypeId : ' + getLeadRecordTypeId('SX_RFPs') );
        //-- get the account object records to update
        for( Account account : [ SELECT Id, Lead_Potential_Revenue__c,
                                          ( SELECT Id, Potential_Revenue__c 
                                            FROM SX_Property_Account__r
                                            WHERE RecordTypeId = : getLeadRecordTypeId('SX_RFPs')
                                                  AND IsConverted = false
                                                  AND Status IN : getLeadStatusList() )
                                 FROM Account 
                                 WHERE Id IN :newSXPropertyAccounts ] ) {   
            //System.debug('account : ' + account );
            decimal totalPotentialRevenue = 0.0;
            //System.debug('account leads : ' + account.Leads__r );
            //--get the list of all leads related to current account object
            for( Lead lead : account.SX_Property_Account__r ) {
                totalPotentialRevenue += lead.Potential_Revenue__c;
            }
            account.Lead_Potential_Revenue__c = totalPotentialRevenue;
            accountsToUpdate.add( account );                 
        } 
        if( !accountsToUpdate.isEmpty() ) {
            update accountsToUpdate; 
        }
    }
    
   
    /**
      * @Description : update Accounts on insert of Leads
     */
    public static void afterInsertLead( List<Lead> leads ) {
        //-- List of account Id`s to be updated
        Set<Id> newSXPropertyAccounts = new Set<Id>();
        //get the Id`s of all lead records affected by insert operation on lead object
        for( Lead lead : leads ) {
            newSXPropertyAccounts.add( lead.SX_Property_Account__c );
        }
        updateLeadPotentialRevenueTotal( newSXPropertyAccounts );
    }     
    
    /**
      * @Description : update Accounts on update of Leads
     */
    public static void afterUpdateLead( Map<Id,Lead> newLeadsMap, Map<Id,Lead> oldLeadsMap ) {        
        //-- List of account Id`s to be updated
        Set<Id> newSXPropertyAccounts = new Set<Id>();
        
        //get the Id`s of all account records affected by Update operation on lead object        
        for( Lead newLead : newLeadsMap.values())
        {
            //get old copy of values of updating lead record
            Lead oldLead = oldLeadsMap.get( newLead.Id );
            
            //if either Amount or media cost field of new Invoice is changed
            if(( newLead.Potential_Revenue__c != oldLead.Potential_Revenue__c ) 
                 || newLead.SX_Property_Account__c != oldLead.SX_Property_Account__c
                 || newLead.RecordTypeId != oldLead.RecordTypeId
                 || newLead.Status != oldLead.Status 
                 || newLead.IsConverted != oldLead.IsConverted ) {
                
                newSXPropertyAccounts.add( newLead.SX_Property_Account__c  );
                newSXPropertyAccounts.add( oldLead.SX_Property_Account__c  );
            }
        }
        updateLeadPotentialRevenueTotal( newSXPropertyAccounts );            
    }
  
    /**
      * @Description : update Accounts on delete of Leads
     */
    public static void afterDeleteLead( List<Lead> oldLeads ) {
        //-- List of account Id`s to be updated
        Set<Id> newSXPropertyAccounts = new Set<Id>();
               
        //get the Id`s of all lead records affected by insert operation on lead object
        for( Lead deletedLead : oldLeads ) {
            newSXPropertyAccounts.add( deletedLead.SX_Property_Account__c );
        }
        updateLeadPotentialRevenueTotal( newSXPropertyAccounts );
    }
    
    /**
      * @Description : update Accounts on undelete of Leads
     */
    public static void afterUndeleteLead( List<Lead> undeletedLeads ) {
        //-- List of account Id`s to be updated
        Set<Id> newSXPropertyAccounts = new Set<Id>();
        
        //get the Id`s of all lead records affected by insert operation on lead object
        for( Lead undeletedLead : undeletedLeads ) {
            newSXPropertyAccounts.add( undeletedLead.SX_Property_Account__c );
        }
        updateLeadPotentialRevenueTotal( newSXPropertyAccounts );          
    }
    
    static Id getLeadRecordTypeId( String recordTypeDeveloperName) {
        return Schema.SObjectType.Lead.getRecordTypeInfosByName().get('SX - RFPs').getRecordTypeId();
    }
    
    static List<String> getLeadStatusList() {
        return new List<String>{ 'New Bid', 
                                 'Bid Sent - Waiting on Response',
                                 'Bid Sent - No Response'
                               };
    }
}