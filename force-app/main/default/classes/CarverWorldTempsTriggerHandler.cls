/* 
* @Description : IN Carver_World_Temps__c Objec insert new Record pickup Default_Jobs__c Fieled Value match with Product Name in opportunityLineItem 
object that product UnitPrice field Value update in Carver_World_Temps__c object Bill_Rate Field.
*/   

public class CarverWorldTempsTriggerHandler {
    
    public static void updateBillRateField(List<Carver_World_Temps__c> carverWorldTempsList){
        
        List<OpportunityLineItem> opportunityLineItemList=new List<OpportunityLineItem>();
        Set<ID> opportunityIdSet=new  Set<ID>();
        
        For(Carver_World_Temps__c carverWorldTemp :carverWorldTempsList){            
            opportunityIdSet.add(carverWorldTemp.CWT_Opportunity__c);
        }
        
        opportunityLineItemList=[SELECT id, Product2.Name,UnitPrice,
                                 OpportunityId, ProductCode 
                                 FROM OpportunityLineItem 
                                 WHERE OpportunityId IN: opportunityIdSet];  
        
        //  check the opportunityLineItemList Empty and Null.
        if(opportunityLineItemList!=Null && !opportunityLineItemList.isEmpty()){
            
            For(Carver_World_Temps__c carverWorldTemp :carverWorldTempsList){
                
                For(OpportunityLineItem opportunityLineItem :opportunityLineItemList){
                    
                    if(carverWorldTemp.CWT_Opportunity__c==opportunityLineItem.OpportunityId 
                       && carverWorldTemp.Default_Jobs__c==opportunityLineItem.Product2.Name) {
                           carverWorldTemp.Bill_Rate__c=opportunityLineItem.UnitPrice;     
                           break;
                       }
                }
            }
            
        }
        
    }
}