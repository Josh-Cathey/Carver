public Class OpportunitySurvey2Controller {
    public List<selectOption> consultantRatingpicklistValues {get; set;}
    public List<selectOption> dressedProfessionalMannerPicklistValues {get; set;}
    public List<selectOption> interactwellHotelMembersAndGuestsPicklistValues {get; set;}
    public List<selectOption> skillSetAppropriateForAssignmentPicklistValues {get; set;}
    public List<selectOption> ifSameNeedAskForSameConsultantPicklistValues {get; set;}
    
    public OpportunitySurvey2Controller(){
        consultantRatingpicklistValues = new List<selectOption>();
        consultantRatingpicklistValues.addAll(getPickValues('Opportunity', 'Did_your_Consultant_achieve_set_goals__c'));
        dressedProfessionalMannerPicklistValues = new List<selectOption>();
        dressedProfessionalMannerPicklistValues.addAll(getPickValues('Opportunity', 'Dressed_Professional_Manner__c'));
        interactwellHotelMembersAndGuestsPicklistValues = new List<selectOption>();
        interactwellHotelMembersAndGuestsPicklistValues.addAll(getPickValues('Opportunity', 'Interact_well_hotel_members_and_guests__c'));
        skillSetAppropriateForAssignmentPicklistValues = new List<selectOption>();
        skillSetAppropriateForAssignmentPicklistValues.addAll(getPickValues('Opportunity', 'Skill_set_appropriate_for_assignment__c'));
        ifSameNeedAskForSameConsultantPicklistValues = new List<selectOption>();
        ifSameNeedAskForSameConsultantPicklistValues.addAll(getPickValues('Opportunity', 'If_same_need_ask_for_same_consultant__c'));
    }


 /**
     *@purpose :To get all values of Picklist. 
     *@param   :a)picklist field Name
     *          b)SobjectName
     *@return  :All picklist options.              
    **/           
    public List<selectOption> getPickValues(String objectName, String fieldName) {
    
        List<selectOption> options = new List<selectOption>();
        System.debug('picklist::');
        Schema.sObjectType sobjectType = Schema.getGlobalDescribe().get(objectName); 
        Schema.DescribeSObjectResult sobject_describe = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPickListValues(); 
        for (Schema.PicklistEntry picklistValue : picklistValues) { 
                  
            options.add(new selectOption(picklistValue.getValue(), picklistValue.getLabel()));
        }
        return options;
    }

    /**
     *@purpose :To Update Opportunity suvery values. 
     *@param   :
     *@return  :-.              
    **/ 
    @RemoteAction
    public static void updateOpportunity(Id opportunityId, String consultantRating, String professionalMannerRating, 
                                         String hotelMembersRating,String skillSetRating, String needAskForSameConsultantRating){

        Opportunity opportunityToUpdate = new Opportunity( Id = opportunityId,
                                                           Did_your_Consultant_achieve_set_goals__c = consultantRating,
                                                           Dressed_Professional_Manner__c = professionalMannerRating,
                                                           Interact_well_hotel_members_and_guests__c = hotelMembersRating,
                                                           Skill_set_appropriate_for_assignment__c = skillSetRating,
                                                           If_same_need_ask_for_same_consultant__c = needAskForSameConsultantRating,
                                                           Survey2__c = true
                                                          ); 
        try{
            UPDATE opportunityToUpdate;
        }catch(Exception exp){
            System.debug('Error in Opportunity Update for suvery2'+exp.getMessage());
        }  
       

    }  
}