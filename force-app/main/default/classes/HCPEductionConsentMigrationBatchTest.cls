@IsTest
public with sharing class HCPEductionConsentMigrationBatchTest {
    @TestSetup
    static void makeData(){
       
        Account testAccount = new Account(Name = 'test');
        insert testAccount;
    }
    @IsTest
    public static void hcpEductionConsentMigrationBatch_Test() {

        Account acc = [Select Id From Account Where Name ='test'];
       
        Contact contact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = acc.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Thailand', BrandName__c = 'GainConnect',ExternalAccountName__c='test',IsEmailVerified__c = true,IsTest__c = false);
        insert contact1;
     EngagementChannelType  channel = new EngagementChannelType();
      channel.Name = 'General';
      channel.ContactPointType = 'web';
      insert channel;

      DataUsePurpose datapurpose = new DataUsePurpose();
      datapurpose.Name = 'Education';
      insert datapurpose;
        
       DataUsePurpose datapurpose1 = new DataUsePurpose();
      datapurpose1.Name = 'Marketing';
      insert datapurpose1;

      BusinessBrand brand1 = new BusinessBrand(
            Name = 'GainConnect'
        );
        insert brand1;

        ContactPointEmail emailconsent1 =new ContactPointEmail(
            EmailAddress = 'test@consent.com'
        );
        insert emailconsent1;
        
         ContactPointEmail emailconsent2 =new ContactPointEmail(
            EmailAddress = 'test2@consent.com'
        );
        insert emailconsent2;
        
        ContactPointConsent consent1 = new ContactPointConsent(
            Name = 'consent1' + '-' + contact1.Id,
            Contact__c = contact1.Id,
            PrivacyConsentStatus = 'Seen',
            CaptureContactPointType = 'Email',
            ContactPointId = emailconsent1.Id,
            BusinessBrandId = brand1.Id,
            DataUsePurposeId = datapurpose.Id
        );
        insert consent1;
        ContactPointConsent consent2 = new ContactPointConsent(
            Name = 'consent2' + '-' + contact1.Id,
            Contact__c = contact1.Id,
            PrivacyConsentStatus = 'Seen',
            CaptureContactPointType = 'Email',
            ContactPointId = emailconsent2.Id,
            BusinessBrandId = brand1.Id,
            DataUsePurposeId = datapurpose1.Id
        );
        insert consent2;

        Test.startTest();
        HCPEductionConsentMigrationBatch bt = new HCPEductionConsentMigrationBatch();
        Database.executeBatch(bt);
        Test.stopTest();
    }
    @IsTest
    public static void hcpEductionConsentMigrationBatch_Test2() {

        Account acc = [Select Id From Account Where Name ='test'];
       
        Contact contact1 = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = acc.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Thailand', BrandName__c = 'GainConnect',ExternalAccountName__c='test',IsEmailVerified__c = true,IsTest__c = false);
        insert contact1;
     EngagementChannelType  channel = new EngagementChannelType();
      channel.Name = 'General';
      channel.ContactPointType = 'web';
      insert channel;
        
        
      DataUsePurpose datapurpose = new DataUsePurpose();
      datapurpose.Name = 'Education';
      insert datapurpose;
        
       DataUsePurpose datapurpose1 = new DataUsePurpose();
      datapurpose1.Name = 'Marketing';
      insert datapurpose1;

      BusinessBrand brand1 = new BusinessBrand(
            Name = 'GainConnect'
        );
        insert brand1;
        
         ContactPointEmail emailconsent2 =new ContactPointEmail(
            EmailAddress = 'test2@consent.com'
        );
        insert emailconsent2;
        
        
        ContactPointConsent consent2 = new ContactPointConsent(
            Name = 'consent2' + '-' + contact1.Id,
            Contact__c = contact1.Id,
            PrivacyConsentStatus = 'Seen',
            CaptureContactPointType = 'Email',
            ContactPointId = emailconsent2.Id,
            BusinessBrandId = brand1.Id,
            DataUsePurposeId = datapurpose1.Id
        );
        insert consent2;

        Test.startTest();
        HCPEductionConsentMigrationBatch bt = new HCPEductionConsentMigrationBatch();
        Database.executeBatch(bt);
        Test.stopTest();
    }
}