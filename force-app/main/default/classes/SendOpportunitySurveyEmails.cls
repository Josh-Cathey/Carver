/************************************************************************************************************************************
@purpose        : Batch class to send survey email to contact email Id.
@created date   : 21-03-2016.
**************************************************************************************************************************************/
public Class SendOpportunitySurveyEmails implements Database.Batchable<sObject>{
   
    public Database.QueryLocator start(Database.BatchableContext SendSurveyEmailBatchContext) {
        String query = 'SELECT Id, Primary_Contact__c, Consultant_Assigned__c, Opportunity.Primary_Contact__r.Name,'+
                        'Extend__c, Opportunity.Primary_Contact__r.Email,Service_Start_Date__c, Service_End_Date__c,'+
                        'Is_Survey1_Email_Send__c, Is_Survey2_Email_Send__c '+
                        'FROM Opportunity '+
                        'WHERE ((Service_Start_Date__c = LAST_N_DAYS:10 AND Is_Survey1_Email_Send__c = false) OR '+
                        '(Extend__c = \'No\' AND Service_End_Date__c = TODAY AND Is_Survey2_Email_Send__c = false))';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext SendSurveyEmailBatchContext, List<Opportunity> opportunityList) {
        
        Set<Opportunity> opportunitySurvey1Set = new Set<Opportunity>();
        Set<Opportunity> opportunitySurvey2Set = new Set<Opportunity>();
        
        opportunitySurvey1Set.addAll(getOpportunitySurvey1Set(opportunityList));
        opportunitySurvey2Set.addAll(getOpportunitySurvey2Set(opportunityList));
        sendSurveyEmails(opportunitySurvey1Set, 1);
        sendSurveyEmails(opportunitySurvey2Set, 2);       
    }

    public void sendSurveyEmails( Set<Opportunity> opportunitySurveySet, Integer surveyNumber) {
        //System.debug('IN Email');
        //System.debug('opportunityList::'+contactIdToOpportunityMapForSurvey.size());
        Map<String, Id> emailTemplateNameToIdMap  = getEmailTemplateNameToIdMap();
        List<Messaging.SingleEmailMessage> surveyEmails;
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        
        if(!opportunitySurveySet.isEmpty() && !emailTemplateNameToIdMap.isEmpty()) {
            surveyEmails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage singleMail;
            for(Opportunity opportunityRec :opportunitySurveySet){
                singleMail = new Messaging.SingleEmailMessage();
                singleMail.setTargetObjectId(opportunityRec.Primary_Contact__c);

                if(surveyNumber == 1)
                    singleMail.setTemplateId(emailTemplateNameToIdMap.get('Opportunity Survey1 Template'));
                else
                    singleMail.setTemplateId(emailTemplateNameToIdMap.get('Opportunity Survey2 Template'));

                singleMail.setWhatId(opportunityRec.Id);
                surveyEmails.add(singleMail);
                opportunityMap.put(opportunityRec.Id, opportunityRec);
            }

            List<Messaging.SendEmailResult>  surveyEmailResults = Messaging.sendEmail(surveyEmails, false);
            updateOpportunitiesWhosMailIsSend(surveyEmailResults, surveyEmails, opportunityMap, surveyNumber);
        }

    }

    public void updateOpportunitiesWhosMailIsSend(List<Messaging.SendEmailResult> emailResults, 
                                                  List<Messaging.SingleEmailMessage> surveyEmails,
                                                  Map<Id, Opportunity> opportunityMap, 
                                                  Integer surveyNumber){

        List<Opportunity> opportunityListToUpdate = new List<Opportunity>();
        for(Integer i=0; i<emailResults.size(); i++) {
                
            if(emailResults[i].isSuccess()) {
                if(surveyNumber ==1){
                    opportunityMap.get(surveyEmails[i].getWhatId()).Is_Survey1_Email_Send__c = true;
                }else{
                    opportunityMap.get(surveyEmails[i].getWhatId()).Is_Survey2_Email_Send__c = true;
                }
                
                opportunityListToUpdate.add(opportunityMap.get(surveyEmails[i].getWhatId()));
            }
        }
        
        try{
            UPDATE opportunityListToUpdate;
        }catch(Exception exp){
            System.debug('Error in opportunityList update::'+exp.getMessage());
        } 
    }

    public Set<Opportunity> getOpportunitySurvey1Set(List<Opportunity> opportunityList) {
        Set<Opportunity> opportunitySurvey1Set = new Set<Opportunity>();
        for(Opportunity OpportunityRec :opportunityList) {
            if(OpportunityRec.Service_Start_Date__c != NULL && OpportunityRec.Service_Start_Date__c.addDays(10) == date.today()) {
                opportunitySurvey1Set.add(OpportunityRec);                
            }
        }
        return opportunitySurvey1Set;
      }

    public Set<Opportunity> getOpportunitySurvey2Set(List<Opportunity> opportunityList) {
        Set<Opportunity> opportunitySurvey2Set = new Set<Opportunity>();

        for(Opportunity OpportunityRec :opportunityList){
           if(OpportunityRec.Extend__c == 'No' && OpportunityRec.Service_End_Date__c == date.today()) {
                opportunitySurvey2Set.add(OpportunityRec);
            }
        }
        return opportunitySurvey2Set;
    }
     
    public Map<String, Id> getEmailTemplateNameToIdMap() {

        Map<String, Id> emailTemplateNameToIdMap  = new Map<String, Id>();

        for(EmailTemplate emailTemplateRec :[SELECT Id, Name FROM EmailTemplate 
                                            WHERE Name IN ('Opportunity Survey1 Template',
                                                           'Opportunity Survey2 Template')]){
            emailTemplateNameToIdMap.put(emailTemplateRec.Name,emailTemplateRec.Id);
        }

        return emailTemplateNameToIdMap;
    }
    public void finish(Database.BatchableContext SendSurveyEmailBatchContext) {
    }
}