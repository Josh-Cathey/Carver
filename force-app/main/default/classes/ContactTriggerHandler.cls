public class ContactTriggerHandler {
    public static List<Contact> getProfilesInReview(Map<Id, Contact> oldRecords, Map<Id, Contact> newRecords) {
        List<Contact> listToReturn = new List<Contact>();
        for(Contact newRecord : [SELECT Id, Name, Consultant_Status__c, Travel_Admin__c FROM Contact WHERE Id IN: newRecords.values()]) {
            if(String.isNotBlank(newRecord.Consultant_Status__c) 
               && String.isNotBlank(newRecord.Travel_Admin__c)
               && newRecord.Consultant_Status__c.equals('Profile in Review')) {
                if(oldRecords != null && oldRecords.size() > 0 && oldRecords.containsKey(newRecord.Id)) {
                    Contact oldRecord = oldRecords.get(newRecord.Id);
                    if(!oldRecord.Consultant_Status__c.equals(newRecord.Consultant_Status__c)) {
                        listToReturn.add(newRecord);
                    }
                }
                else{
                    listToReturn.add(newRecord);
                }
            }
        }
        return listToReturn;
    }
    
    public static void submitContactsForApproval(List<Contact> contactList) {
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        
        for(Contact contactRec : contactList) {
            // Create an approval request for the account
            Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
            approvalReq.setComments('Submitting request for approval.');
            approvalReq.setObjectId(contactRec.id);
            
            // Submit on behalf of a specific submitter
            approvalReq.setSubmitterId(UserInfo.getUserId()); 
            
            // Submit the record to specific process and skip the criteria evaluation
            approvalReq.setProcessDefinitionNameOrId('Consultant_Status_Profile_In_Review');
            approvalRequests.add(approvalReq);
        }
        try {
            // Submit the approval request for the account
            List<Approval.ProcessResult> result = Approval.process(approvalRequests);
            System.debug('Approval Result:::'+JSON.serialize(result));
        }
        catch(Exception e) {
            System.debug('Exception caught while submitting approval request'+e.getMessage());
        }
    }
}