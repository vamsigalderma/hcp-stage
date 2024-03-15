/*******************************************************************************************
* @Name         ContactServiceTest
* @Author       Vamsi Krishna
* @Description  This is the test class for ContactTrigger, ContactTriggerHandler and ContactService.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          		Date               Description
*-------------------------------------------------------------------------------------------
*  1.0            Vamsi Krishna Mopidevi    08/11/2023         Initial Creation.
*******************************************************************************************/
@isTest
public with sharing class HCPUSerRegistrationControllerTest {
    @TestSetup
    static void makeData(){
        //create
    }

    //check duplicate contacts test
    public static testmethod void checkDuplicateEmailsTest() {
        Boolean isDuplicate = HCPUserRegistrationController.checkDuplicateContacts('vmopidevi@salesforce.com','Germany');
        System.assert(!isDuplicate);
    }
    //Get picklist values
    public static testmethod void getPicklistvalues() {
        HCPUserRegistrationController.getPicklistValues();
    }
    //test form submission
    public static testmethod void getPicklistValuesTest() {
        Map<String, Object> picklistDataMap = HCPUserRegistrationController.getPicklistValues();
        System.assert(picklistDataMap.containsKey('Salutation'), 'Salutation must ne available for Germany');
    }

    //Submit flow
    public static testmethod void submitRegistrationTest() {
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'test@test.commm';
        wrapper.organization = 'test';
        wrapper.firstname = 'test';
        wrapper.lastname = 'test';
        wrapper.zipcode = 'test';
        wrapper.state = 'test';
        wrapper.city = 'test';
        wrapper.gender = 'Male';
        wrapper.address = 'test';
        wrapper.medicalid = 'test';
        wrapper.phone = '1231231233';
        wrapper.profession = 'Doctor';
        wrapper.title = 'Mr.';
        wrapper.privacyconsent = true;
        wrapper.marketingconsent = true;
        wrapper.licensingconsent = true;
        String returnValue  = HCPUserRegistrationController.submitRegistration(wrapper);
        Map<String,String> resultMap  = HCPUserRegistrationController.submitRegistrationBrazil(wrapper);
        System.assert(returnValue == 'Success');
    }
    @IsTest
    private static void uploadFile_Test() {
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
       HCPUSerRegistrationController.uploadFile('testData','testFile',testContact.Id,'frontImage');

        Test.stopTest();
    }

}