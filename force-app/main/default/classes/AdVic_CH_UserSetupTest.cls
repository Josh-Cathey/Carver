/**
 * Created by Holden.Parker on 1/31/22.
 */

@IsTest
private class AdVic_CH_UserSetupTest {

    @IsTest
    static void testWiredOptionsSuccess() {
        Test.startTest();
        AdVic_CH_UserSetup.wireDelphiStandardOptions();
        AdVic_CH_UserSetup.wireLanguagesOptions();
        AdVic_CH_UserSetup.wireBrandsOptions();
        AdVic_CH_UserSetup.wireFamilyOfBrandsOptions();
        AdVic_CH_UserSetup.wirePropertyStateOptions();
        AdVic_CH_UserSetup.wireEmploymentMonthOptions();
        AdVic_CH_UserSetup.wireEmploymentYearOptions();
        AdVic_CH_UserSetup.wireStillWorkingThereOptions();
        Test.stopTest();
    }

    @IsTest(SeeAllData = true)
    static void testFetchInitDataSuccess() {
        User registeredBuyer = [
                SELECT Id, Name, Profile.Name FROM User WHERE IsActive = TRUE
                AND Profile.Name = 'Carver - Partner Community Login User' LIMIT 1
        ];

        System.runAs(registeredBuyer) {
            Test.startTest();
            Map<String, Object> result = AdVic_CH_UserSetup.fetchInitData();
            System.assertEquals(true, result.containsKey('data'));
            Test.stopTest();
        }
    }

    @IsTest
    static void testSaveAllDataSuccess() {
        Account account = new Account(
                Name = 'Test Account'
        );
        insert account;

        Contact contact = new Contact(
                FirstName = 'Test',
                LastName = 'Account'
        );
        insert contact;

        ContentVersion cv = new ContentVersion();
        cv.Title = 'ABC';
        cv.PathOnClient = 'test';
        cv.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        Map<String, Object> saveData = new Map<String, Object>{
            'contact' => contact,
            'brands' => new List<Brands__c>(),
            'jobExperience' => new List<Job_Experience__c>(),
            'contentVersionId' => cv.Id
        };

        Test.startTest();
        Map<String, Object> result = AdVic_CH_UserSetup.saveAllData(saveData);
        System.assertEquals(true, result.containsKey('data'));
        Test.stopTest();
    }

}