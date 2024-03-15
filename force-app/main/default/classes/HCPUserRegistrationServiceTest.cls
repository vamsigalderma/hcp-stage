@IsTest
public with sharing class HCPUserRegistrationServiceTest {
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
    private static void populateEmailVerificationKey_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',isEmailVerified__c = false, isVerificationEmailSent__c =false);
           Contact testContact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',isEmailVerified__c = false, isVerificationEmailSent__c =false);

        List<Contact> testContactList = new List<Contact>();
        testContactList.add(testContact);
       testContactList.add(testContact1);
       HCPUserRegistrationService.populateEmailVerificationKey(testContactList);

        Test.stopTest();
    }
    
}