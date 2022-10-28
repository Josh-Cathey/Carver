public Class JopOpeningAlertResponseController{
    /**
     *@purpose :
     *@param   :  
     *@return  :-.              
    **/ 
    @RemoteAction
    public static void updateEligibleConsultant(Id eligibleConsultantId, String response){

        Eligible_Consultant__c eligibleConsultant = new Eligible_Consultant__c( Id = eligibleConsultantId, Interested__c = response); 
        try{
            UPDATE eligibleConsultant;
        }catch(Exception exp){
            System.debug('Error in Eligible Consultant Update for Jop Opening alert response - ' + exp.getMessage());
        }  
    }  
}