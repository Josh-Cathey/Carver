public Class OpportunitySurvey1Controller {
    /**
     *@purpose :To Update Opportunity suvery values. 
     *@param   : a)opportunityId
     *           b)suvery1Reply from customer through email. 
     *@return  :-.              
    **/ 
    @RemoteAction
    public static void updateOpportunity(Id opportunityId, String suvery1Reply){

        Opportunity opportunityToUpdate = new Opportunity( Id = opportunityId, Thumbs_Up_or_Down__c = suvery1Reply, Survey1__c = true); 
        try{
            UPDATE opportunityToUpdate;
        }catch(Exception exp){
            System.debug('Error in Opportunity Update for suvery1'+exp.getMessage());
        }  
    }  
}