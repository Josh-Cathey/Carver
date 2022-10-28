/**
 * Created by Holden.Parker on 1/17/22.
 */

public without sharing class AdVic_CH_UserSetup {

    private static Contact saveContact { set; get; }

    @AuraEnabled
    public static Map<String, Object> saveAllData(Map<String, Object> saveData) {
        Map<String, Object> result = new Map<String, Object>();

        try {
            System.debug('CONTACT SAVE DATA: ' + saveData);
            saveContact = (Contact) JSON.deserialize(JSON.serialize(saveData.get('contact')), Contact.class);
            List<Brands__c> brands = (List<Brands__c>) JSON.deserialize(
                    JSON.serialize(saveData.get('brands')), List<Brands__c>.class
            );
            List<Job_Experience__c> jobExperience = (List<Job_Experience__c>) JSON.deserialize(
                    JSON.serialize(saveData.get('jobExperience')), List<Job_Experience__c>.class
            );

            if (saveData.containsKey('contentVersionId')) {
                appendProfilePicUrlOnContact((String) saveData.get('contentVersionId'));
            }

            Database.Update(saveContact);
            Database.upsert(brands, false);
            Database.upsert(jobExperience, false);

            result.put('data', true);
            if (brands.size() > 0) {
                result.put('brands', brands);
            }
            if (jobExperience.size() > 0) {
                result.put('jobExperience', jobExperience);
            }
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }

        return result;
    }

    private static void appendProfilePicUrlOnContact(String contentVersionId) {
        ContentDistribution cd = new ContentDistribution();
        cd.Name = saveContact.FirstName + ' ' + saveContact.LastName + '\'s Profile Pic';
        cd.ContentVersionId = contentVersionId;
        cd.PreferencesNotifyOnVisit = false;
        insert cd;

        ContentDistribution distribution = [
                SELECT Name, ContentDownloadUrl
                FROM ContentDistribution WHERE Id =: cd.Id
        ];

        saveContact.ProfileImageUrl__c = distribution.ContentDownloadUrl;
    }

    @AuraEnabled
    public static Map<String, Object> fetchInitData() {
        Map<String, Object> result = new Map<String, Object>();

        try {
            Contact contact = fetchContact();

            if (contact != null) {
                List<Brands__c> brands = fetchBrands(contact.Id);
                List<Job_Experience__c> jobExperience = fetchJobExperience(contact.Id);

                result.put('data', new Map<String, Object>{
                        'contact' => contact,
                        'brands' => brands,
                        'jobExperience' => jobExperience
                });
            }
        } catch (Exception e) {
            result.put('error', e.getMessage());
        }

        return result;
    }

    public static Contact fetchContact() {
        return [
                SELECT Id, ProfileImageUrl__c, FirstName, LastName, Legal_Name__c, Phone, MobilePhone, Email, Delphi__c,
                MailingStreet, MailingCity, MailingState, MailingPostalCode, Languages__c, Main_Discipline__c, CI_TY__c,
                Envision__c, ISAC__c, SalesPro__c, SFA__c, Opera__c, OnQ__c, Galaxy_LightSpeed__c, Opera_Cloud__c,
                Fosse__c, Marsha__c, Other_Automated_Sytems__c, Other_PMS_Systems__c, Other_Languages__c, CI_TY_EID__c,
                CI_TY_Date_Certified__c, Delphi_Standard_or_FDC__c, Current_Salary__c, Minimum_Salary_Requirement__c,
                Will_Relocate__c, Current_Position_Title__c, Other_Country_Citizen__c, US_Citizen__c
                FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())
        ];
    }

    public static List<Brands__c> fetchBrands(String contactId) {
        List<Brands__c> brands = new List<Brands__c>();
        try {
            brands = new List<Brands__c>([
                    SELECT Id, Consultant__c, Consultant_Contact__c, Family_of_Brands__c, Brands__c, Other_Brand__c
                    FROM Brands__c WHERE Consultant_Contact__c = :contactId
            ]);
        } catch (Exception exp) { System.debug('Fetch Brands Exception :: ' + exp.getMessage()); }
        if (brands.isEmpty()) brands.add(new Brands__c(Consultant_Contact__c = contactId));
        return brands;
    }

    public static List<Job_Experience__c> fetchJobExperience(String contactId) {
        List<Job_Experience__c> jobExperience = new List<Job_Experience__c>();
        try {
            jobExperience = new List<Job_Experience__c>([
                    SELECT Id, Consultant__c, Hotel_Property_Name__c, Property_City__c, Property_State__c,
                    Job_Title__c, Start_Date_Month__c, Start_Date_Year__c, End_Date_Month__c, End_Date_Year__c,
                    Are_You_Still_Working_There__c, of_Sleeping_Rooms__c, SqFt_of_Meeting_Space__c,
                    of_Restaurant_Seats__c, Markets__c, Achievement_1__c, Achievement_2__c, Achievement_3__c,
                    Achievement_4__c, Achievement_5__c
                    FROM Job_Experience__c WHERE Consultant__c = :contactId
            ]);
        } catch (Exception exp) { System.debug('Fetch Job Experience Exception :: ' + exp.getMessage()); }
        if (jobExperience.isEmpty()) jobExperience.add(new Job_Experience__c(Consultant__c = contactId));
        return jobExperience;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireDelphiStandardOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Contact.Delphi_Standard_or_FDC__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        options.add(new Map<String, String>{ 'value' => '', 'label' => 'None' });

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireLanguagesOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Contact.Languages__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static Map<String, List<Object>> wireBrandsOptions() {
        Schema.DescribeFieldResult depend = Brands__c.Brands__c.getDescribe();
        Schema.sObjectField controlToken = depend.getController();

        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries = control.getPicklistValues();

        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<Object>> dependentPicklistValues = new Map<String, List<Object>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ?   (Object) (index == 1)
                                    :   (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if  (controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<Object>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(new Map<String, String>{ 'value' => entry.getValue(), 'label' => entry.getLabel() });
                }
            }
        }
        return dependentPicklistValues;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireFamilyOfBrandsOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Brands__c.Family_of_Brands__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wirePropertyStateOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Job_Experience__c.Property_State__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireEmploymentMonthOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Job_Experience__c.Start_Date_Month__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireEmploymentYearOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Job_Experience__c.Start_Date_Year__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

    @AuraEnabled(Cacheable = true)
    public static List<Object> wireStillWorkingThereOptions() {
        List<Object> options = new List<Object>();

        Schema.DescribeFieldResult fieldResult = Job_Experience__c.Are_You_Still_Working_There__c.getDescribe();
        List<Schema.PicklistEntry> picklistValueList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry value : picklistValueList) {
            options.add(new Map<String, String>{ 'value' => value.getValue(), 'label' => value.getLabel() });
        }

        return options;
    }

}