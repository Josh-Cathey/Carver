/*
* Name : ServicePositionProduct 
* Purpose : ServicePositionProduct trigger fire before insert and before update Service_Positions__c records
* Created Date : 
*/

trigger ServicePositionProduct on Service_Positions__c (before insert,before update){

    if(Trigger.isBefore){
    
        //for insert
        if(Trigger.isInsert){
           
           ServicePositionProductHandler.updateServiceposition(Trigger.New); 
        }else if(Trigger.isUpdate){
            
            //for update
            List<Service_Positions__c> servicePositionList = new List<Service_Positions__c>();
            
            for(Service_Positions__c servicePosition : Trigger.New){ 
                
                Service_Positions__c oldServicePosition = Trigger.oldMap.get(servicePosition.Id);
                
                // check old record is not same as new 
                if(oldServicePosition.Position_Title__c != servicePosition.Position_Title__c){
                
                    servicePositionList.add(servicePosition);
                }
              
            
            }
            
            // check is any record is updated
            if(!servicePositionList.IsEmpty()){
                ServicePositionProductHandler.updateServiceposition(servicePositionList);
            }
            
        }
    }       
}