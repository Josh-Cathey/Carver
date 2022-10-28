public with sharing class EligibleConsultantWrapper{

        public String recordId {get; set;}
        public String name {get; set;}
        public String interested {get; set;}
        public String status {get; set;}
        public Boolean CI_TY {get; set;}
        public Boolean delphi {get; set;}
        public Boolean envision {get; set;}
        public Boolean ISAC {get; set;}
        public Boolean salesPro {get; set;}
        public String averageSurveyGrade {get; set;}
        public String consultantRating {get; set;}
        
        public EligibleConsultantWrapper(Contact eligibleConsultant){
            recordId = eligibleConsultant.Id;  
            name = eligibleConsultant.Name.replaceAll('\'','&apos;');
            if(eligibleConsultant.Eligible_Consultants__r != NULL && !eligibleConsultant.Eligible_Consultants__r.isEmpty()){
                interested = eligibleConsultant.Eligible_Consultants__r[0].Interested__c==''?'-':eligibleConsultant.Eligible_Consultants__r[0].Interested__c;
                status = eligibleConsultant.Eligible_Consultants__r[0].Status__c==''?'-':eligibleConsultant.Eligible_Consultants__r[0].Status__c;
            }else{
                interested = '-';
                status = '-';
            }
            CI_TY = eligibleConsultant.CI_TY__c;
            delphi = eligibleConsultant.Delphi__c;
            envision = eligibleConsultant.Envision__c;
            ISAC = eligibleConsultant.ISAC__c;
            salesPro = eligibleConsultant.SalesPro__c;
            averageSurveyGrade = eligibleConsultant.Average_Survey_Grade__c;
            System.debug('consultantRating : ' + consultantRating);
            //consultantRating = String.valueOf(eligibleConsultant.Consultant_Rating__c).replaceAll('"','*');
            consultantRating = String.valueOf(eligibleConsultant.Consultant_Rating__c).split('"')[1];
            System.debug('after consultantRating : ' + consultantRating);
        }
        
        public EligibleConsultantWrapper(Contact consultant,
                                         Eligible_Consultant__c eligibleConsultant){
            recordId = consultant.Id;  
            name = consultant.Name.replaceAll('\'','&apos;');
            if(eligibleConsultant != NULL){
                interested = eligibleConsultant.Interested__c==''?'-':eligibleConsultant.Interested__c;
                status = eligibleConsultant.Status__c==''?'-':eligibleConsultant.Status__c;
            }else{
                interested = '-';
                status = '-';
            }
            CI_TY = consultant.CI_TY__c;
            delphi = consultant.Delphi__c;
            envision = consultant.Envision__c;
            ISAC = consultant.ISAC__c;
            salesPro = consultant.SalesPro__c;
            averageSurveyGrade = consultant.Average_Survey_Grade__c;
            System.debug('consultantRating : ' + consultantRating);
            //consultantRating = String.valueOf(consultant.Consultant_Rating__c).replaceAll('"','*');
            consultantRating = String.valueOf(consultant.Consultant_Rating__c).split('"')[1];
            System.debug('after consultantRating : ' + consultantRating);
        }
    }