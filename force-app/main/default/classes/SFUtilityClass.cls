/**
 * Utility class for reguler SF operations.
 * @Created Date : 27-04-2017
 * @Authors      : Dreamwares
 */
global with sharing class SFUtilityClass {
    
    public enum ApexDMLOption { APEX_INSERT, APEX_UPDATE, APEX_DELETE, APEX_UNDELETE, APEX_MERGE }
    public enum ApexTriggerType { BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE, AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE, AFTER_UNDELETE }
    
    private static SFUtilityResult SFUtilityResultInstance;
        
    /** 
     * Method to handle apex DML operations.(bulkify)
     * @Param       sObjectList, sObject list for DML operation
     * @Param       SFobjectName, API name of base Object.
     * @Param       dmlOperation, contains specific DML operation to be done.
     * @Returns     Boolean for DML success.
     */
    public static SFUtilityResult apexDMLHandler(List<sObject> sObjectList, String SFobjectName, ApexDMLOption dmlOperation) {
        SFUtilityResultInstance = new SFUtilityResult();
        List<sObject> records = getTypeCastedSObjectList(SFobjectName);
        if(records != null) {
            records.addAll(sObjectList);        
            try {
                if(dmlOperation.name().equalsIgnoreCase(ApexDMLOption.APEX_UPDATE.name())) {
                    update records;
                    SFUtilityResultInstance.isSuccess = true;
                    SFUtilityResultInstance.displayMessage = 'Data ' + dmlOperation.name() + ' Successful!';
                    SFUtilityResultInstance.result = records;
                }
            } catch(Exception exp) {
                logMessageFromException(exp);
                SFUtilityResultInstance.displayMessage = 'Data ' + dmlOperation.name() + ' Failuer!';
            }
            return SFUtilityResultInstance;
        }
        SFUtilityResultInstance.displayMessage = 'Object Not Found --> ' + SFobjectName;
        return SFUtilityResultInstance;
    }
    
    /** 
     * Method returns the recordtype Id(string) from it's name 
     * @Param       SFobjectName, SF Object API name.
     * @Param       recordTypeName, RecordType name of same Object.
     * @Returns     String(ID)
     */
    public static SFUtilityResult getObjectRecordTypeId(String SFobjectName, String recordTypeName) {
        String recordTypeId = '';
        SFUtilityResultInstance = new SFUtilityResult();
        
        // Check sObject Availability in Org.
        SFUtilityResultInstance = checkSObjectAvailability(SFobjectName);
        if (!SFUtilityResultInstance.isSuccess) {
            SFUtilityResultInstance.displayMessage = 'Object Not Found --> ' + SFobjectName;
            return SFUtilityResultInstance;
        }
        
        // Get sObjectType result.
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(SFobjectName);
        if (objType == null){
            SFUtilityResultInstance.isSuccess = false;
            SFUtilityResultInstance.displayMessage = 'Object Type Retrieve Failure For Object --> ' + SFobjectName;
            return SFUtilityResultInstance;
        }
        
        //Generate a map of tokens for all the Record Types for the desired object
        Map<string, schema.recordtypeinfo> recordTypeInfo = objType.getDescribe().getRecordTypeInfosByName();
    
        if(!recordTypeInfo.containsKey(recordTypeName)) {
            SFUtilityResultInstance.isSuccess = false;
            SFUtilityResultInstance.displayMessage = 'Record Type "'+ recordTypeName +'" Does Not Exist For Object --> '+ SFobjectName;
            throw new RecordTypeException('Record type "'+ recordTypeName +'" does not exist.');
        } else {
            //Retrieve the record type id by name
            recordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
            SFUtilityResultInstance.displayMessage = 'Record Type Id Retrieved Successful!';
            SFUtilityResultInstance.result = new List<Object>{recordTypeId};
        }        
        return SFUtilityResultInstance;
    }
    
    /** 
     * Method returns Type Casted SObject list.
     * @Param       SFobjectName, SF Object API name.
     * @Returns     List Of Type Casted sObject List.
     */
    public static List<SObject> getTypeCastedSObjectList(String SFobjectName) {
        SFUtilityResultInstance = new SFUtilityResult();
        SFUtilityResultInstance = checkSObjectAvailability(SFobjectName);
        if(SFUtilityResultInstance.isSuccess) {
            Type sObjectListType = Type.ForName('List<' + SFobjectName + '>');             
            return (List<SObject>) sObjectListType.newInstance();
        }
        return null;
    }
    
    /**
     * Method for check sObject Availability.
     * @Param       objName, API name of SF object(standard/custom)
     * @Returns     Boolean is assure presence of object in SF.
     */
    public static SFUtilityResult checkSObjectAvailability(String objName) {
        SFUtilityResultInstance = new SFUtilityResult();
        //get the string to sobject global map
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        SFUtilityResultInstance.isSuccess = Schema.getGlobalDescribe().containsKey(objName);
        SFUtilityResultInstance.displayMessage = (SFUtilityResultInstance.isSuccess) ? 
                                                  'sObject Available In Org' :
                                                  'sObject Not Available In Org';
        return SFUtilityResultInstance;
    }
    
    /** 
     * Display the exception message.
     * @Param       exp, Instance of Exception class.
     * @Returns     -
     */
    public static void logMessageFromException(Exception exp) {       
        String strErrorMessage;
        if(exp != Null) {        
            strErrorMessage = '\n Error Message:-{0} \n Error LineNumber:-{1}';
            List<String> listOfMessageTokens = new List<String>{exp.getMessage(), String.valueOf(exp.getLineNumber())};
            strErrorMessage = String.format(strErrorMessage, listOfMessageTokens);
        }
        System.debug(strErrorMessage);
    }
    
    /*********************************
     * Following section is Read Only.  *
     *********************************/
    
    /**
     * Public class to throw custom Exception.
     * @Created Date    : 03-04-2017
     */
    public class RecordTypeException extends Exception{}
}