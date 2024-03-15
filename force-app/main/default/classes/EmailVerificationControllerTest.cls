@IsTest
public with sharing class EmailVerificationControllerTest {
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
    private static void updateContactRecord_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab-975f-d560-4074-11ee69e1c744-1701269941959-03401');
          
                insert testContact;

                //Verification time is expired
                DateTime myDateTime = DateTime.newInstance(2024, 1, 1, 14, 30, 0); // Represents August 21, 2023, 2:30:00 PM
                testContact.VerificationLinkExpiryDateTime__c = myDateTime;
             update testContact;

        List<Id> testContactList = new List<Id>();
        testContactList.add(testContact.Id);
       EmailVerificationController.updateContactRecord(testContact.EmailVerificationKey__c);

        Test.stopTest();
    }

    @IsTest
    private static void updateContactRecord_Test2() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',
                EmailVerificationKey__c = 'cfedc7ab');
                insert testContact;
                 //Verification time is expired
                DateTime dt = Datetime.now().addDays(5);
                   testContact.VerificationLinkExpiryDateTime__c = dt;
             update testContact;
        List<Id> testContactList = new List<Id>();
        testContactList.add(testContact.Id);
       EmailVerificationController.updateContactRecord(testContact.EmailVerificationKey__c);

        Test.stopTest();
    }

    @IsTest
    private static void updateContactRecord_Test3() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab');
          
                insert testContact;
               //Verification time is null 
               DateTime myDateTime = DateTime.newInstance(2024, 1, 1, 14, 30, 0); // Represents August 21, 2023, 2:30:00 PM
               testContact.VerificationLinkExpiryDateTime__c = null;
               testContact.isEmailVerified__c  = true;
            update testContact;

                List<Id> testContactList = new List<Id>();
       testContactList.add(testContact.Id);
       EmailVerificationController.updateContactRecord(testContact.EmailVerificationKey__c);

        Test.stopTest();
    }
}