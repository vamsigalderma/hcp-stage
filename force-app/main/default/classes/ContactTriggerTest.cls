@IsTest
public class ContactTriggerTest {

    @TestSetup
    static void makeData() {
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        insert new Contact(AccountId = testAccount.Id, LastName = 'Test contact with cases', MailingCountry = 'Brazil', BrandName__c = 'RX',
         CIAMId__c = '12345678999999', Email = 'existing@test.com',ExternalAccountName__c='test');
        insert new Contact(AccountId = testAccount.Id, LastName = 'Test contact with cases', MailingCountry = 'Brazil', BrandName__c = 'cetaphil',
               CIAMId__c = '12345678999999',ExternalAccountName__c='test2', Email = 'existing@test.com');
    }

    @IsTest
    private static void shouldCreateCase_WhenUserGainConnectBrazil_Test() {
        String brazilGainConnectUserName = 'Brazil GainConnect';
        User gainConnectBrazilUser = [SELECT Id FROM User WHERE Name = :brazilGainConnectUserName];

        Test.startTest();
        System.runAs(gainConnectBrazilUser) {
            Account testAccount = new Account(Name = 'test');
            insert testAccount;
            insert new Contact(FirstName = 'Michael', LastName = 'Existing', Email = 'test@testemail.com', Email_External__c = 'test@testemail.com',
                    TrustLevel__c = 'Unknown', CIAMId__c = '12345678913468', NPIId__c = 'A_test', AccountId = testAccount.Id,
                    MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '888888888');
        }
        Test.stopTest();

       // System.assertEquals(TestHelper.getCases().size(), 1, 'A Case should have been created');
    }

    @IsTest
    private static void shouldNotSaveContact_WhenConsentButNoPhoneNumber_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test');
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test');

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
        Database.SaveResult[] contactUpsertResult = Database.insert(testContactList, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];

        System.assertEquals(2, listOfContacts.size(), 'No new Contact should have been created');
		System.assertEquals('This contact has Phone Consent but no phone number filled, you should add the phone number.',
        contactUpsertResult[0].getErrors()[0].getMessage(), 'The error message is wrong');
    }
    
    @IsTest
    private static void createAndInsertCasesForBrands_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
        Database.SaveResult[] contactUpsertResult = Database.insert(testContactList, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];

        System.assertEquals(2, listOfContacts.size(), 'No new Contact should have been created');
   		System.assertEquals('This contact has Phone Consent but no phone number filled, you should add the phone number.',
        contactUpsertResult[0].getErrors()[0].getMessage(), 'The error message is wrong');
        ContactService.createAndInsertCasesForBrands(testContactList);
        
    }
    @IsTest
    private static void checkIfContactHasFilledPhoneNumberWithConsent_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
        Database.SaveResult[] contactUpsertResult = Database.insert(testContactList, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];
        System.debug('++' +  JSON.serialize(contactUpsertResult[0].getErrors()));
        System.assertEquals(2, listOfContacts.size(), 'No new Contact should have been created');
        System.assertEquals('This contact has Phone Consent but no phone number filled, you should add the phone number.',
        contactUpsertResult[0].getErrors()[0].getMessage(), 'The error message is wrong');
        ContactService.checkIfContactHasFilledPhoneNumberWithConsent(testContactList);
        
    }
    @IsTest
    private static void createMultiPicklistWhenWhenInsert_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
        Database.SaveResult[] contactUpsertResult = Database.insert(testContactList, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];

        System.assertEquals(2, listOfContacts.size(), 'No new Contact should have been created');
        System.assertEquals('This contact has Phone Consent but no phone number filled, you should add the phone number.',
        contactUpsertResult[0].getErrors()[0].getMessage(), 'The error message is wrong');
        ContactService.createMultiPicklistWhenWhenInsert(testContactList);
        
    }
    @IsTest
    private static void sAPCDCMakeCallout_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect', Phone = '',ExternalAccountName__c='test');

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
        Database.SaveResult[] contactUpsertResult = Database.insert(testContactList, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];

        System.assertEquals(2, listOfContacts.size(), 'No new Contact should have been created');
        System.assertEquals('This contact has Phone Consent but no phone number filled, you should add the phone number.',
        contactUpsertResult[0].getErrors()[0].getMessage(), 'The error message is wrong');
        ContactService.sAPCDCMakeCallout(testContactList);
        
    }
    public static testmethod void setPhoneNumberInCorrectFormat_Test() {   
      Test.startTest();            
       Account testAccount = new Account(Name = 'test');
        insert testAccount;
       
        List<Contact> listcon = new List<Contact>();
        contact con = new contact();
        con.lastname='test';
        con.email='test1234@gmail.com';
        con.AccountId=testAccount.id;
        con.BrandName__c='cetaphil';
        con.mailingcountry='US';
        con.Phone='1234567890';       
        
        listcon.add(con);        
        insert listcon;        
        
         
        Database.SaveResult[] contactUpsertResult = Database.insert(listcon, false);

        Test.stopTest();
        List<Contact> listOfContacts = [
                SELECT Id, Name, Email, CIAMId__c
                FROM Contact
        ];

        
        
        List<CountryCode__c> licc = new List<CountryCode__c>();
        CountryCode__c cc = new CountryCode__c();
        cc.name='Puerto Rico';
        cc.Code__c='1-787';
        licc.add(cc);
        insert licc;
        
         Map<String, String> countryCodesByCountry = new Map<String, String>();
        // List<CountryCode__c> countryCodeList = [SELECT Name, Code__c FROM CountryCode__c];    
         for (CountryCode__c countryCode : licc) {
         countryCodesByCountry.put(countryCode.Name, countryCode.Code__c);
         }    
        
        Map<Id, Contact> oldMap = new Map<Id, Contact>();
        for(contact conn :listcon){
            oldMap.put(conn.id,conn);
        }
        ContactService.setPhoneNumberInCorrectFormat(listcon,oldMap);
        
    }
    
    @isTest
    static void testprocessContactPointConsentRecord()
    {
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Consent',
            Email = 'test@consent.com',
            BrandName__c = 'Cetaphil',
            HasOptedOutofEmail = true
        );
        insert contact1;
        
        BusinessBrand brand1 = new BusinessBrand(
            Name = 'Cetaphil'
        );
        insert brand1;
        
        ContactPointEmail emailconsent1 =new ContactPointEmail(
            EmailAddress = 'test@consent.com'
        );
        insert emailconsent1;
        
        ContactPointConsent consent1 = new ContactPointConsent(
            Name = 'consent1',
            Contact__c = contact1.Id,
            PrivacyConsentStatus = 'Seen',
            CaptureContactPointType = 'Email',
            ContactPointId = emailconsent1.Id,
            BusinessBrandId = brand1.Id
        );
        insert consent1;
        
        List<Contact> newContacts = new List<Contact>();
        Map<Id, Contact> OldMapContacts = new Map<Id, Contact>();
        OldMapContacts.put(contact1.Id, new Contact(id=contact1.Id));
        contact1.HasOptedOutOfEmail = false;
        update contact1;
        newContacts.add(contact1);
        
        Test.startTest();
        // ContactService.processContactPointConsentRecord(newContacts, OldMapContacts);
        Test.stopTest();
    }
    
    @isTest
    static void testprocessContactPointConsentRecordforTrue()
    {        
        Contact contact1 = new Contact(
            FirstName = 'Test',
            LastName = 'Consent',
            Email = 'test@consent.com',
            BrandName__c = 'Cetaphil',
            HasOptedOutofEmail = false
        );
        insert contact1;
        
        BusinessBrand brand1 = new BusinessBrand(
            Name = 'Cetaphil'
        );
        insert brand1;
        
        ContactPointEmail emailconsent1 =new ContactPointEmail(
            EmailAddress = 'test@consent.com'            
        );
        insert emailconsent1;
        
        ContactPointConsent consent1 = new ContactPointConsent(
            Name = 'consent1',
            Contact__c = contact1.Id,
            PrivacyConsentStatus = 'Seen',
            CaptureContactPointType = 'Email',
            ContactPointId = emailconsent1.Id,
            BusinessBrandId = brand1.Id
        );
        insert consent1;
        
        List<Contact> newContacts = new List<Contact>();
        Map<Id, Contact> OldMapContacts = new Map<Id, Contact>();
        OldMapContacts.put(contact1.Id, new Contact(id=contact1.Id));
        contact1.HasOptedOutOfEmail = true;
        update contact1;
        newContacts.add(contact1);
        
        Test.startTest();
        // ContactService.processContactPointConsentRecord(newContacts, OldMapContacts);
        Test.stopTest();
    }

    
}