/*
 * @Description An apex class handles all the trigger functionality on Lead object
 */
public class LeadTriggerHandler {
    
    /* @Description A method creates Accounts and Contacts after lead insert 
     * @Param : list of Lead object records
     * @return: -
     */
    public static void createAccountAndContacts(List<Lead> listNewLeads) {
        
        List<Database.LeadConvert> listLeadsToConvert;
        Database.LeadConvert leadConverterObj;
        List<Contact> listContacts;
        List<User> listPortalUsers;
        set<Id> setContactIds;
        LeadStatus convertStatus;
        User communityUser;
        profile portalProfile;
        
        if(!listNewLeads.isEmpty()) {
            listLeadsToConvert = new List<Database.LeadConvert>();
            convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = true LIMIT 1];
            for(Lead leadObj : listNewLeads) {               
                if(!(leadObj.Status.equals('Qualified') || leadObj.Status.equals('Converted')) && leadObj.Status.equals('Recruiter')) {
                    leadConverterObj  = new Database.LeadConvert();
                    leadConverterObj.setLeadId(leadObj.id);
                    leadConverterObj.setDoNotCreateOpportunity(true);
                    leadConverterObj.setConvertedStatus(convertStatus.MasterLabel);
                    listLeadsToConvert.add(leadConverterObj);
                }
            }
            if(listLeadsToConvert.size() > 0) {
            
                setContactIds = new Set<Id>();                
                Database.LeadConvertResult[] LeadConvertResult = Database.ConvertLead(listLeadsToConvert, true );                
                try {
                    portalProfile = [SELECT Id, name FROM Profile WHERE UserLicense.Name = 'Customer Community' AND name LIKE '%Consultant%' LIMIT 1];
                } catch(Exception exp) { System.debug('Profile fetch Exception : ' + exp.getMessage()); }
                if(portalProfile != null){
                    for(Integer index=0; index < LeadConvertResult.size(); index++) {
                        if(LeadConvertResult[index].isSuccess()) {
                            setContactIds.add(LeadConvertResult[index].getContactId());
                        }                        
                    }
                    listContacts = new List<Contact>([SELECT Id,FirstName,LastName,Email FROM Contact WHERE Id IN :setContactIds]);
                    if(listContacts.size() > 0) {
                        listPortalUsers = new List<User>();
                        String strContactEmail;
                        for(Integer index=0; index < LeadConvertResult.size(); index++) {
                            communityUser = new User();                        
                            strContactEmail = listContacts[index].Email;
                            communityUser.Email = strContactEmail;
                            strContactEmail = strContactEmail.Replace(strContactEmail.SubString((strContactEmail.indexOf('@')+1)),'chgcommunity.com');
                            communityUser.Username = strContactEmail;
                            communityUser.FirstName = listContacts[index].FirstName;
                            communityUser.LastName = listContacts[index].LastName;                            
                            communityUser.emailencodingkey = 'UTF-8';
                            communityUser.contactId = listContacts[index].id;
                            communityUser.ProfileId = portalProfile.Id;
                            communityUser.Alias = listContacts[index].FirstName.substring(0,2) + listContacts[index].LastName.substring(0,2) + String.valueOf(Math.round(Math.random()*1000));
                            communityUser.TimeZoneSidKey = 'America/Los_Angeles';
                            communityUser.LocaleSidKey = 'en_US';
                            communityUser.LanguageLocaleKey = 'en_US';
                            //communityUser.CommunityNickname = '';
                            //u.IsPortalSelfRegistered = true;
                            listPortalUsers.add(communityUser);
                        }
                        if(listPortalUsers.size() > 0) {
                            try {
                                insert listPortalUsers;
                            } catch(Exception exp) { System.debug('User Insert Exception :: ' + exp.getMessage()); }
                        }
                    }
                }
            }
        }        
    }
}