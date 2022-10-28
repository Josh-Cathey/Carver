/*
* Name : ServicePositionProductHandler
* Purpose : To handle ServicePositionProduct trigger
* Created Date : 
*/
public class ServicePositionProductHandler{

    /*
    *    To update service position record
    */
    public static void updateServiceposition(List<Service_Positions__c> ServicePositionList){
 
        //it only fires if the picklist is filled in
        System.debug('In method');
        Set<String> positionTitleSet = new Set<String>();
        Map<String, Service_Positions__c> servicePositionMap = new Map<String, Service_Positions__c>();
        
        for (Service_Positions__c servicePosition: ServicePositionList) {
           // check position Titel present or not
           if(servicePosition.Position_Title__c != null) { 
            
                positionTitleSet.add(servicePosition.Position_Title__c);
            }
        }
    
        List<Product2> productionIdList = new List<Product2>();
         Map<String, Id> productMap = new Map<String, Id>();
        
        //get product records
        try{
        
            productionIdList = [Select Id, Name from Product2 WHERE Name IN : positionTitleSet];
        }catch(Exception e){
            
            System.debug('Exception:::'+e.getMessage());
        }
        
        // product list having values or not
        if(productionIdList.size() > 0){
        
            for(Product2 product : productionIdList){
            
                productMap.put(product.Name, product.Id);
            }
            
            for (Service_Positions__c servicePosition: ServicePositionList) {
               // check position Titel present or not
               if(servicePosition.Position_Title__c != null) { 
                
                    if(productMap.containsKey(servicePosition.Position_Title__c)){
                    
                       servicePosition.Service_Position__c = productMap.get(servicePosition.Position_Title__c);
                    }
                }
            }
                    
        }
        
    }
}