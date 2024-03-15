@isTest
public with sharing class CommunityAuthControllerTest {
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
            UserName ='randomuser@salesforceTest.com'
        );
        insert guestUser;
        Account testAccount = new Account(Name = 'test');
        insert testAccount;
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
        insert con;
        User usr = HCPUSerRegistrationController.getUserRecord(con, wrapper);
        usr.ContactId = con.Id;
        usr.MigratedFromCDC__c = true;
        insert usr;
        
        //Create a new contact
        //Create user
        HCPUSerRegistrationController.InputDataWrapper wrapper1 = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper1.emailaddress = 'test@test.commm';
        wrapper1.organization = 'test';
        wrapper1.firstname = 'test';
        wrapper1.lastname = 'test';
        wrapper1.zipcode = 'test';
        wrapper1.state = 'test';
        wrapper1.city = 'test';
        wrapper1.gender = 'Male';
        wrapper1.address = 'test';
        wrapper1.medicalid = 'test';
        wrapper1.phone = '1231231233';
        wrapper1.profession = 'Doctor';
        wrapper1.title = 'Mr.';
        wrapper1.privacyconsent = true;
        wrapper1.marketingconsent = true;
        wrapper1.licensingconsent = true;
        wrapper1.password = 'TestGalderma1@1';
        String returnValue  = HCPUserRegistrationController.submitRegistration(wrapper1);
        //Assign Permission Set
    }
    //do login test
    public static testmethod void doLoginTest() {
        User userrec = [SELECT Id FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Test.startTest();
        //Query user
        System.runAs(userrec) {
            try {
                CommunityAuthController.doLogin('test@test.commm','TestGalderma1@1','');
            }
            catch(Exception e) {

            }
            
        }
        
        Test.stopTest();
    }
     //do login test without privacy consent
     public static testmethod void doLoginConsentTest() {
        User userrec = [SELECT Id FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'randomuser@salesforceTest2232.com'];
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            con.PrivacyConsent__c = false;
            update con;
        }
        Test.startTest();
        //Query user
        System.runAs(userrec) {
            try {
                CommunityAuthController.doLogin('randomuser@salesforceTest2232.com','TestGalderma1@1','');
            }
            catch(Exception e) {

            }
            
        }
        
        Test.stopTest();
    }

    //Migrated User Testing
    public static testmethod void checkMigratedUserTest() {
        
        User userrec = [SELECT Id FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usr = [SELECT Id FROM User WHERE Email = 'randomuser@salesforceTest2232.com'];
            List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = 'GainConnect_Brazil_Access'];
            insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps[0].Id);
        }
        Test.startTest();
        System.runAs(userrec) {
            String isMigratedUser = CommunityAuthController.checkMigratedUser('randomuser@salesforceTest2232.com');
            System.assert(isMigratedUser == 'MigratedUser', 'User is not migarted ' + isMigratedUser);
        }
       
        Test.stopTest();

    }

    //Migrated User Testing
    public static testmethod void checkNotVerifiedUser() {
        
        User userrec = [SELECT Id FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        Contact con = [SELECT Id FROM Contact WHERE Email = 'randomuser@salesforceTest2232.com'];
        con.IsEmailVerified__c = false;
        update con;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User usr = [SELECT Id FROM User WHERE Email = 'randomuser@salesforceTest2232.com'];
            usr.MigratedFromCDC__c = false;
            update usr;
        }
        Test.startTest();
        System.runAs(userrec) {
            String isMigratedUser = CommunityAuthController.checkMigratedUser('randomuser@salesforceTest2232.com');
            System.assert(isMigratedUser == 'UserNotVerified', 'User is not migarted ' + isMigratedUser);
        }
       
        Test.stopTest();

    }
    //Migrated User Testing
    public static testmethod void checUserNotValidated() {
        
        User userrec = [SELECT Id FROM User WHERE UserName = 'randomuser@salesforceTest.com'];
        // Contact con = [SELECT Id FROM Contact WHERE Email = 'randomuser@salesforceTest2232.com'];
        // con.IsEmailVerified__c = false;
        // update con;
        // System.runAs(new User(Id = UserInfo.getUserId())) {
        //     User usr = [SELECT Id FROM User WHERE Email = 'randomuser@salesforceTest2232.com'];
        //     usr.MigratedFromCDC__c = false;
        //     update usr;
        // }
        CommunityAuthController obj = new CommunityAuthController();
        Test.startTest();
        System.runAs(userrec) {
            String isMigratedUser = CommunityAuthController.checkMigratedUser('randomuser@salesforceTest2232.com');
            System.assert(isMigratedUser == 'UserNotValidated', 'User is not migarted ' + isMigratedUser);
        }
       
        Test.stopTest();

    }
}