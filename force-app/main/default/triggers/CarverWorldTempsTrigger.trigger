/*
  * @Description A Trigger define an actions Before insert new Carver_World_Temps__c records.  
  * @created Date: 30 September, 2016
*/
trigger CarverWorldTempsTrigger on Carver_World_Temps__c (before insert) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        CarverWorldTempsTriggerHandler.updateBillRateField(Trigger.new);
    }
    
}