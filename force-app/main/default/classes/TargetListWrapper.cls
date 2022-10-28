/**/
global with sharing class TargetListWrapper {
    
      global class contactDTO{
          
          public String recordId {get; set;}
          public String name {get; set;}
          public String desiredSalary;
          
          public String noOfRoom;
          public String mailingCity;
          public String mailingState;
          
          public Boolean willRelocate;
          public Boolean uSCitizen;      
          public Boolean unionExperience;
          
          public Boolean isChecked;
          public Boolean isTargetListPresent;

          
          global contactDTO(Contact contactRec, Boolean isTargetListPresent){
              this.isChecked= isTargetListPresent;
              this.isTargetListPresent = isTargetListPresent;
              
              this.recordId = contactRec.Id;
              this.name = contactRec.Name; 
              this.desiredSalary = contactRec.Current_Salary__c != null ? String.valueOf(contactRec.Current_Salary__c) : '';
              
              this.noOfRoom = contactRec.of_Rooms__c != null ? String.valueOf(contactRec.of_Rooms__c) : ''; 
              this.mailingCity = contactRec.MailingCity != null ? String.valueOf(contactRec.MailingCity) : ''; 
              this.mailingState = contactRec.MailingState != null ? String.valueOf(contactRec.MailingState) : ''; 
              
              this.willRelocate = contactRec.Will_Relocate__c; 
              this.uSCitizen = contactRec.US_Citizen__c;          
              this.unionExperience = contactRec.Union_Experience__c;
    
          }
      }
      
      public class filterDTO{
          public Boolean StateFilter;
          public Boolean familyOfBrandsFilters;
          public Boolean noOfRoomsFilter;
          public Boolean desiredSalary;
          
          public filterDTO(){}
      }
      
      public class OpportunityDTO {
          public String recordId;
          public String familyOfHotelBrand;
          public String state;
          public Integer noOfRoom;
          public String salaryLowRangeFactor;
          public String salaryHighRangeFactor;
          
          public OpportunityDTO() {}
      }
}