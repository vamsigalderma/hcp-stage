@isTest
public class ContactServiceTest {
    
    @TestSetup
    static void makeData(){
        //Create a new Account
        Account testAccount = new Account(Name = 'test');
        insert testAccount;
        //Insert Data Use Purpose Records
        insert new List<DataUsePurpose> {
            new DataUsePurpose(Name = 'Marketing'),
            new DataUsePurpose(Name = 'License Agreement'), new DataUsePurpose(Name = 'Privacy')
        };

        //Insert Enagement Channel Records
        insert new List<EngagementChannelType> {
            new EngagementChannelType(Name = 'Email'), new EngagementChannelType(Name = 'Phone'),
            new EngagementChannelType(Name = 'General')
        };
        //Insert Brand Records
        insert new BusinessBrand(Name = 'GainConnect');
    }

    public static testmethod void testConsentChanges() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        //Create a new contact
        Contact con = new Contact(
            AccountId = acc.Id, 
            LastName = 'Test contact with cases', 
            MailingCountry = 'Brazil', 
            BrandName__c = 'GainConnect',
            CIAMId__c = '12345678999999',
            Email = 'existing@test.com',
            HasOptedOutOfEmail = true,
            et4ae5__HasOptedOutOfMobile__c = false,
            PrivacyConsent__c = true,
            LicenseAgreementConsent__c = false,
            phone = '123444'
        );
        insert con;
        
        List<Contact> contacts = [
            SELECT 
                Id,
                (
                    SELECT 
                    Id, PrivacyConsentStatus, DataUsePurpose.Name,CaptureContactPointType, BusinessBrand.Name, EngagementChannelType.Name
                    FROM Contact_Point_Consents__r
                ),
            IndividualId
            FROM Contact 
            WHERE ID =: con.Id];
        //Asserts for updated consents
        Map<String, String> dataToEngagementMapping = new Map<String, String>{
            'Marketing+Email' => 'Email',
            'Marketing+Phone' => 'Phone',
            'Privacy+Email' => 'General',
            'License Agreement+Email' => 'General'
        };
        Map<String, String> subscribeMapping = new Map<String, String>{
            'Marketing+Email' => 'OptOut',
            'Marketing+Phone' => 'OptIn',
            'Privacy+Email' => 'OptIn',
            'License Agreement+Email' => 'OptOut'
        };

        System.assertEquals(contacts[0].Contact_Point_Consents__r.size(), 4, 'Consent records for Email, Phone, License and Privacy should be created');
        System.assert(String.isNotBlank(contacts[0].IndividualId), 'Individual record should be created for every contact');

        for(ContactPointConsent consent : contacts[0].Contact_Point_Consents__r) {
            String key = consent.DataUsePurpose.Name + '+' + consent.CaptureContactPointType;
            System.assertEquals(consent.EngagementChannelType.Name, dataToEngagementMapping.get(key),
                'Enagegment Channel Type is not mapped correctly for Data Use Purpose Record ' + consent.DataUsePurpose.Name);
            System.assertEquals(consent.PrivacyConsentStatus, subscribeMapping.get(key),
            'Enagegment Channel Type is not mapped correctly for Data Use Purpose Record ' + consent.DataUsePurpose.Name);
        }
        //Test update scenario
        Test.startTest();
        TriggerSkipperUtility.resetTriggerRun('Contact', 'After', true);
		TriggerSkipperUtility.resetTriggerRun('Contact', 'Before', true);
        con.HasOptedOutOfEmail = false;
        con.et4ae5__HasOptedOutOfMobile__c = true;
        con.PrivacyConsent__c = false;
        con.LicenseAgreementConsent__c = true;
        update con;
        //Asserts
        contacts = [
            SELECT 
                Id,
                (
                    SELECT 
                    Id, PrivacyConsentStatus, DataUsePurpose.Name,CaptureContactPointType, BusinessBrand.Name, EngagementChannelType.Name
                    FROM Contact_Point_Consents__r
                ),
            IndividualId
            FROM Contact 
            WHERE ID =: con.Id];
        for(ContactPointConsent consent : contacts[0].Contact_Point_Consents__r) {
            String key = consent.DataUsePurpose.Name + '+' + consent.CaptureContactPointType;
            System.assertEquals(consent.EngagementChannelType.Name, dataToEngagementMapping.get(key),
                'Enagegment Channel Type is not mapped correctly for Data Use Purpose Record ' + consent.DataUsePurpose.Name);
            System.assert(consent.PrivacyConsentStatus != subscribeMapping.get(key),
            'Enagegment Channel Type is not mapped correctly for Data Use Purpose Record ' + consent.DataUsePurpose.Name);
        }
        Test.stopTest();
        
    }
}