@IsTest
public with sharing class HCPUserMigrationBatchTest {
    @TestSetup
    static void makeData(){
        //Guest User Creation
        Profile guestProfile = [SELECT Id FROM Profile WHERE Name = 'Galderma General Profile' AND UserLicense.Name = 'Guest User License' LIMIT 1];

        //Create our test guest user
        User guestUser = new User(
            Alias = 'random',
            Email='random@salesforce.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'random',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ProfileId = guestProfile.Id,
            TimeZoneSidKey ='America/Los_Angeles',
            UserName ='randomuser@salesforceTest.com',
            IsPasswordChanged__c = false
        );
        insert guestUser;
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        insert new Contact(AccountId = testAccount.Id, LastName = 'Test contact with cases', MailingCountry = 'Brazil', BrandName__c = 'RX',
         CIAMId__c = '12345678999999', Email = 'existing@test.com',ExternalAccountName__c='test');
        insert new Contact(AccountId = testAccount.Id, LastName = 'Test contact with cases', MailingCountry = 'Brazil', BrandName__c = 'cetaphil',
               CIAMId__c = '12345678999999',ExternalAccountName__c='test2', Email = 'existing@test.com');
    }
    @IsTest
    public static void HCPUserMigrationBatchTest() {

        Id profileId = [Select Id From Profile Where Name ='Galderma General Profile'].Id;
        Account acc = TestUtilityController.createAccount('Test Account');
        insert acc;
        Contact con = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = acc.Id, HasPhoneConsentRecord__c = true,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test');
        User u = TestUtilityController.createCommunityUser(con.Id,profileId,'test','user11');

        Test.startTest();
        HCPUserMigrationBatch bt = new HCPUserMigrationBatch('CIAMID__c != NULL');
        Database.executeBatch(bt);
        Test.stopTest();

        
    }

    
}