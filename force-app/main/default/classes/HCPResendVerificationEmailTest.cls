@IsTest
private class HCPResendVerificationEmailTest {
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
    private static void sendVerification_Test() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab-975f-d560-4074-11ee69e1c744-1701269941959-03401',
                                          VerificationLinkExpiryDateTime__c = System.now(),isVerificationEmailSent__c = true);
          
                insert testContact;

        SingleRequestMock fakeResponse1 = new SingleRequestMock(testContact.Email,true);
        String JsonMsg=JSON.serialize(fakeResponse1);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/resendEmailVerification?sendEmail=true';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HCPResendVerificationEmail.sendVerificationLink();
        Test.stopTest();
    }
    @IsTest
    private static void sendVerification_Test1() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'test@testik.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab-975f-d560-4074-11ee69e1c744-1701269941959-03401',
                                          VerificationLinkExpiryDateTime__c = System.now() + 7, isVerificationEmailSent__c = true);
          
                insert testContact;

        SingleRequestMock fakeResponse1 = new SingleRequestMock(testContact.Email,true);
        String JsonMsg=JSON.serialize(fakeResponse1);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/resendEmailVerification';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HCPResendVerificationEmail.sendVerificationLink();
        Test.stopTest();
    }
    @IsTest
    private static void sendVerification_Test2() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'tee@gmail.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab-975f-d560-4074-11ee69e1c744-1701269941959-03401',
                                          VerificationLinkExpiryDateTime__c = System.now(), isVerificationEmailSent__c = false);
          
                insert testContact;

                Task ts = new Task();
                ts.Subject = 'test Subject';
                ts.TaskSubtype = 'Email';
                ts.WhoId = testContact.Id;
                insert ts;

        SingleRequestMock fakeResponse1 = new SingleRequestMock(testContact.Email,true);
        String JsonMsg=JSON.serialize(fakeResponse1);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/resendEmailVerification';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HCPResendVerificationEmail.sendVerificationLink();
        Test.stopTest();
    }
    @IsTest
    private static void sendVerification_Test3() {
        Test.startTest();
        Account testAccount = new Account(Name = 'test');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Mike', LastName = 'New', Email = 'tee@gmail.com', Email_External__c = 'test@testik.com',
                TrustLevel__c = 'Unknown', CIAMId__c = '12345678911111',phone='', NPIId__c = 'A_test', AccountId = testAccount.Id, HasPhoneConsentRecord__c = false,
                MailingCountry = 'Brazil', BrandName__c = 'GainConnect',ExternalAccountName__c='test',EmailVerificationKey__c = 'cfedc7ab-975f-d560-4074-11ee69e1c744-1701269941959-03401',
                                          isEmailverified__c = true);
          
                insert testContact;

        SingleRequestMock fakeResponse1 = new SingleRequestMock(testContact.Email,true);
        String JsonMsg=JSON.serialize(fakeResponse1);

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/resendEmailVerification';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        HCPResendVerificationEmail.sendVerificationLink();
        Test.stopTest();
    }
        public class SingleRequestMock {

        public String email;
        public Boolean sentEmail;


        public SingleRequestMock (String email,Boolean sentEmail) {
            this.email = email;
            this.sentEmail = sentEmail;
        }
        }
}