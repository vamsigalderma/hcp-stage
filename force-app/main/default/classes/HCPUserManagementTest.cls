@isTest
public without sharing class HCPUserManagementTest {
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
    public static void checkUserTest() {
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Test.startTest();
        //Query user
        System.runAs(userrec) {
            try {
                HCPUserManagement.checkUser('random@salesforce.com');
            }
            catch(Exception e) {

            }
            
        }
        
        Test.stopTest();
    }
    @IsTest
    public static void resetGcUserPasswordTest() {
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Test.startTest();
        //Query user
        System.runAs(userrec) {
            try {
                HCPUserManagement.resetGcUserPassword('random@salesforce.com');
            }
            catch(Exception e) {

            }
            
        }
        
        Test.stopTest();
    }

    @IsTest
    public static void updateUserRecordTest() {
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Test.startTest();
        //Query user
        System.runAs(userrec) {
            try {
                HCPUserManagement.updateUserRecord();
                HCPUserManagement.getLoginUrl();
            }
            catch(Exception e) {

            }
            
        }
        
        Test.stopTest();
        
    }
    @IsTest
    public static void updateUserAccessTest(){
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'randomuser@salesforceTest2232.com';
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
        wrapper.password = 'TestGalderma1@1';
        wrapper.country = 'Germany';
        
        Contact con = HCPUSerRegistrationController.getContactRecord(wrapper);
        con.IsEmailVerified__c = true;
        insert con;
        User usr = HCPUSerRegistrationController.getUserRecord(con, wrapper);
        usr.ContactId = con.Id;
        insert usr;
        List<case> cases = [SELECT Id FROM Case WHERE ContactId =: con.Id LIMIT 1];
        for(Case tempCase : cases) {
            tempCase.Status = 'Pending Manual Validation';
            tempCase.OwnerId = UserInfo.getUserId();
        }
        update cases;
        system.runAs(new User(Id = UserInfo.getUserId())){
           
            System.assert(cases.size() >= 1, 'Cases size is: ' + cases.size());
            for(Case tempCase : cases) {
                tempCase.Status = 'Closed - denied';
                tempCase.Reason = 'New problem';
            }
            Test.startTest();
            update cases;
            Test.stopTest();
            
        }
       
        
    }

    @isTest
    public static void updateUserAccessValidatedTest(){
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'randomuser@salesforceTest2232.com';
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
        wrapper.password = 'TestGalderma1@1';
        wrapper.country = 'Germany';
        
        Contact con = HCPUSerRegistrationController.getContactRecord(wrapper);
        con.IsEmailVerified__c = true;
        insert con;
        User usr = HCPUSerRegistrationController.getUserRecord(con, wrapper);
        usr.ContactId = con.Id;
        insert usr;
        List<case> cases = [SELECT Id FROM Case WHERE ContactId =: con.Id LIMIT 1];
        for(Case tempCase : cases) {
            tempCase.Status = 'Pending Manual Validation';
            tempCase.OwnerId = UserInfo.getUserId();
        }
        update cases;
        system.runAs(new User(Id = UserInfo.getUserId())){
           
            System.assert(cases.size() >= 1, 'Cases size is: ' + cases.size());
            for(Case tempCase : cases) {
                tempCase.Status = 'Closed - verified';
                //tempCase.Reason = 'New problem';
            }
            Test.startTest();
            update cases;
            Test.stopTest();
            
        }
       
        
    }

    @isTest
    public static void updateUserAccessValidatedTestException(){
        User userrec = [SELECT Id,email FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'randomuser@salesforceTest2232.com';
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
        wrapper.password = 'TestGalderma1@1';
        wrapper.country = 'Germany';
        
        Contact con = HCPUSerRegistrationController.getContactRecord(wrapper);
        con.IsEmailVerified__c = true;
        insert con;
        User usr = HCPUSerRegistrationController.getUserRecord(con, wrapper);
        usr.ContactId = con.Id;
        insert usr;
        system.runAs(new User(Id = UserInfo.getUserId())) {
            List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = 'GainConnect_Germany_Access'];
            insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps[0].Id);
        }
        List<case> cases = [SELECT Id FROM Case WHERE ContactId =: con.Id LIMIT 1];
        for(Case tempCase : cases) {
            tempCase.Status = 'Pending Manual Validation';
            tempCase.OwnerId = UserInfo.getUserId();
        }
        update cases;
        system.runAs(new User(Id = UserInfo.getUserId())){
           
            System.assert(cases.size() >= 1, 'Cases size is: ' + cases.size());
            for(Case tempCase : cases) {
                tempCase.Status = 'Closed - verified';
                //tempCase.Reason = 'New problem';
            }
            Test.startTest();
            try {
                update cases;
            }
            catch(Exception e) {

            }
            
            Test.stopTest();
            
        }
       
        
    }
    

    
}