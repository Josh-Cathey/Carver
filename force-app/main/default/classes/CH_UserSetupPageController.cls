/**
 * An apex page controller that exposes the site User Setup functionality.
 */
global class CH_UserSetupPageController {

    public Contact contactObj         { get; set; }
    public List<Brands__c> listBrands { get; set; }    
    public List<Job_Experience__c> listJobExperiences { get; set; }
    public String communityLandingURL {get; set;}
    public Boolean isLastStep {get; set;}
    public List<Attachment> attachmentList {get; set;}
    /** 
     * Get Delphi_Standard_or_FDC__c picklist values
     */
    public List<SelectOption> getDelphiStandard(){
        List<SelectOption> options = new List<SelectOption>();
         
        Schema.DescribeFieldResult fieldResult = Contact.Delphi_Standard_or_FDC__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();
        
        options.add(new SelectOption('','None'));
        
        for( Schema.PicklistEntry value : picklistValueList){
            options.add(new SelectOption(value.getValue(), value.getLabel()));
        }
        
        return options;
    }
    
    /* @description : Initialize the controller's variables.
     * @param  : -
     * @return : -
     */
    public CH_UserSetupPageController() {
    
        try{
            contactObj = [SELECT Id,ProfileImageUrl__c,FirstName,LastName,Legal_Name__c,Phone,MobilePhone,Email,MailingStreet,MailingCity,
                          MailingState,MailingPostalCode,Languages__c,Main_Discipline__c,CI_TY__c,Delphi__c,Envision__c,ISAC__c,SalesPro__c,
                          SFA__c,Opera__c,OnQ__c,Galaxy_LightSpeed__c,Opera_Cloud__c,Fosse__c,Marsha__c,Other_Automated_Sytems__c,Other_PMS_Systems__c,
                          Other_Languages__c,CI_TY_EID__c,CI_TY_Date_Certified__c,Delphi_Standard_or_FDC__c,Current_Salary__c,
                          Minimum_Salary_Requirement__c,Will_Relocate__c,Current_Position_Title__c,Other_Country_Citizen__c,US_Citizen__c
                          FROM Contact 
                          WHERE Id In (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
            /*contactObj = [SELECT Id,ProfileImageUrl__c,FirstName,LastName,Legal_Name__c,Phone,MobilePhone,Email,MailingStreet,MailingCity,MailingState,MailingPostalCode,Languages__c,Main_Discipline__c,CI_TY__c,Delphi__c,Envision__c,ISAC__c,SalesPro__c,SFA__c,Opera__c,OnQ__c,LightSpeed__c,Maestro__c,Fosse__c,Marsha__c,Other_Automated_Sytems__c,Other_PMS_Systems__c,Other_Languages__c 
                          FROM Contact 
                          WHERE Id  = '003f000000omKP4'];*/
        } catch(Exception exp) { System.debug('Contact Fetch Exception :: ' + exp.getMessage()); }
        if(contactObj != null) {
            try{
                listBrands = new List<Brands__c>([SELECT Id,Consultant__c,Consultant_Contact__c,Family_of_Brands__c,Brands__c,Other_Brand__c 
                                                  FROM Brands__c 
                                                  WHERE Consultant_Contact__c = :contactObj.id]);
            } catch(Exception exp) { System.debug('Fetch Brands Exception :: ' + exp.getMessage()); }
            
            try{
                listJobExperiences = new List<Job_Experience__c>([SELECT Id,Consultant__c,Hotel_Property_Name__c,Property_City__c,Property_State__c,Job_Title__c,Start_Date_Month__c,Start_Date_Year__c,End_Date_Month__c,End_Date_Year__c,Are_You_Still_Working_There__c,of_Sleeping_Rooms__c,SqFt_of_Meeting_Space__c,of_Restaurant_Seats__c,Markets__c,Achievement_1__c,Achievement_2__c,Achievement_3__c,Achievement_4__c,Achievement_5__c
                                                                  FROM Job_Experience__c 
                                                                  WHERE Consultant__c = :contactObj.id]);
            } catch(Exception exp) { System.debug('Fetch Brands Exception :: ' + exp.getMessage()); }
            
            if(listJobExperiences.isEmpty()) {
                listJobExperiences.add(new Job_Experience__c(Consultant__c = contactObj.id));
            }
            if(listBrands.isEmpty()) {
                listBrands.add(new Brands__c(Consultant_Contact__c = contactObj.id));
            }
        } else {
            listBrands = new List<Brands__c>();
            listJobExperiences = new List<Job_Experience__c>();
        }
        
        // Set community landing URL
        communityLandingURL = System.Site.getBaseSecureUrl();
        isLastStep = false;
    }
    
    /* @description : Prepare the list of picklist values of 'Property State' field on Job Experience.
     * @param  : -
     * @return : Landing Page of community.
     */
    public void saveAllData() {
        
        contactObj.Languages__c = ApexPages.currentPage().getParameters().get('langs');
        String strProfileImgURL = ApexPages.currentPage().getParameters().get('ProfileImgURL');
        String currentStep = ApexPages.currentPage().getParameters().get('currentStep');
        System.debug('Languages ==>'+ApexPages.currentPage().getParameters().get('langs'));
        System.debug('strProfileImgURL==>'+strProfileImgURL);
        System.debug('currentStep==>'+currentStep);
        
        if(currentStep == '#fift-step'){
            isLastStep = true;
            System.debug('isLastStep ::'+isLastStep);
        }
        
        if(String.isNotBlank(strProfileImgURL)) {
            contactObj.ProfileImageUrl__c = strProfileImgURL;
        }        
        System.debug('contactObj.ProfileImageUrl__c :: ' + contactObj.ProfileImageUrl__c);
        System.debug('contactObj.Delphi_Standard_or_FDC__c :: ' + contactObj.Delphi_Standard_or_FDC__c);
        Database.Update(contactObj);
        
        System.debug('listBrands : ' + listBrands);
        Database.upsert(listBrands, false);
        
        System.debug('listJobExperiences : ' + listJobExperiences);
        Database.upsert(listJobExperiences, false);
        //return null;
        //return Network.communitiesLanding();
    }
    
    /* @description : upsert attachment for Contact.
     * @param  : 1)contId         : As ParentId for Attachment
                 2)attachmentBody : String Encoded Attachment Body.
                 3)attachmentName : Name Of File
                 4)attachmentId   : Attachment Id in String Format If the same previously inserted.
                 5)fileType       : To check file type of attachment.
                 6)attCount       : current count of attachment for same parent.
     * @return : string(Id) of attachment
     */
    @RemoteAction
    Global Static String doUploadAttachment(String contId, String attachmentBody, String attachmentName,
                                            String attachmentId, String fileType, String attCount, Boolean isBigFile, Boolean isDelete ) {
        System.debug('Attachment Body : ' + attachmentName);
        Attachment att;    
        String strImgAttachmentUrl;
        String deletedAttachId ='';                                        
        
        if(String.isNotBlank(attachmentBody)) {
            if(attachmentBody.startsWith('data:')){
                attachmentBody = attachmentBody.substringAfter(',');
            }
            // If attachment Id is already present in insertedAttachmentList delete It
            if( String.isNotBlank(attachmentId) && isDelete ) {
               deletedAttachId = attachmentId;
               delete [select id from Attachment where id=:attachmentId];
               
            }
            // Getting previous inserted attachment
            if(String.isNotBlank(attachmentId) && !isDelete ) {
                att = getAttachment(attachmentId);
                system.debug('Inside Old Att');
            } else {
                // Create new attachment
                att = new Attachment();
            }
            String newBody = '';
            
            // if attachment body is not equlals to NULL and file is big size file
            if( att.Body != null && isBigFile ) {
            //if( att.Body != null ) {
                newBody = EncodingUtil.base64Encode(att.Body);
                System.debug('newBody==>'+newBody);
            }
            
            newBody += attachmentBody;
            att.Body = EncodingUtil.base64Decode(newBody);
            att.Name = attachmentName;
            
            if( String.isBlank(attachmentId) || isDelete ) {                
                att.parentId = contId;
            }
            if(!Test.isRunningTest()) {
                Database.upsert(att);
            }
            if(fileType.equals('profile')) {
                strImgAttachmentUrl = '/servlet/servlet.FileDownload?file=' + att.id;
            }
        }
        // returning attachment Id, attachment count, filetype, attachment file type, attachment name.                                         
        return att.id + '|' + strImgAttachmentUrl + '|' + attCount + '|' + fileType + '|' + att.Name + '|' + deletedAttachId;
    }
    
    /* @description : Prepare list of attachment for Contact.
     * @param  : string(Id) attachment record Id
     * @return : Attachment object
     */
    public static Attachment getAttachment(String attId) {
        Attachment contAttachment;
        if(String.isNotBlank(attId)) {
            try {
                contAttachment = [SELECT Id, Body, Name
                                  FROM Attachment 
                                  WHERE Id =: attId];
            } catch(Exception exp) { System.debug('Attachment Exception :: ' + exp.getMessage()); }
        } else {
            contAttachment  = new Attachment();
        }
        return contAttachment;
    }
    
    /* @description : Prepare list of options from external function.
     * @param  : String as parent value
     * @return : list of string(options)t
     */
    @RemoteAction
    Global Static String getDependentBrands(String strParentValue, String Bindex, String strSelectedValues) {
        return String.join(PicklistFieldController.getDependentOptionsImpl('Brands__c', 'Family_of_Brands__c', 'Brands__c').get(strParentValue), ',') + '|' + Bindex + '|' + strSelectedValues;
    }
    
    /* @description : Set list of options from Parameters.
     * @param  : -
     * @return : PageReference
     */
    public PageReference setDependentBrands() {
        Integer updateBrandIndex;
        try {
               updateBrandIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('bUpdateIndex'));
        } catch(Exception e) { System.debug('Exception :: ' + e.getMessage()); }
        if((--updateBrandIndex) <= listBrands.size()) {
            listBrands[updateBrandIndex].Brands__c = ApexPages.currentPage().getParameters().get('listBrands');
        }
        return null;
        //return String.join(PicklistFieldController.getDependentOptionsImpl('Brands__c', 'Family_of_Brands__c', 'Brands__c').get(strParentValue), ',') + '|' + Bindex + '|' + strSelectedValues;
    }
    
    /* @description : Add new JobExperience to list of JobExperience for Contact.
     * @param  : -
     * @return : -
     */
    public void addNewJobExperience() {
        if(contactObj != null){
            listJobExperiences.add(new Job_Experience__c(Consultant__c = contactObj.id));
        }
    }
    
    /* @description : Remove JobExperience given by 'jeIndex' from list of JobExperience.
     * @param  : -
     * @return : -
     */
    public void removeJobExperience() {
        Integer deleteJobExpIndex;
        try {
               deleteJobExpIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('jeIndex'));    
        } catch(Exception e) { System.debug('Exception :: ' + e.getMessage()); }
           
        System.debug('deleteJobExpIndex :: ' + deleteJobExpIndex);
        if(deleteJobExpIndex <= listJobExperiences.size()){
            Job_Experience__c JobExpbj = listJobExperiences.remove(deleteJobExpIndex-1);
            if(String.isNotBlank(JobExpbj.id)){
                Database.Delete(JobExpbj);
            }
        }
        //System.debug('listJobExperiences :: ' + listJobExperiences);
    }    
    
    /* @description : Add new brand to list of brands for Contact.
     * @param  : -
     * @return : -
     */
    public void addNewBrand() {
        if(contactObj != null){
            listBrands.add(new Brands__c(Consultant_Contact__c = contactObj.id));
        }
    }
    
    /* @description : Remove brand given by 'bIndex' from list of brands.
     * @param  : -
     * @return : -
     */
    public void removeBrand() {
        Integer deleteBrandIndex;
        try {
               deleteBrandIndex = Integer.valueOf(ApexPages.currentPage().getParameters().get('bIndex'));    
        } catch(Exception e) { System.debug('Exception :: ' + e.getMessage()); }
           
        System.debug('deleteBrandIndex :: ' + deleteBrandIndex);
        if(deleteBrandIndex <= listBrands.size()){
            Brands__c brandObj = listBrands.remove(deleteBrandIndex-1);
            if(String.isNotBlank(brandObj.id)){
                Database.Delete(brandObj);
            }
        }
        System.debug('listBrands :: ' + listBrands);
    }   
}