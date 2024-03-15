@isTest
public with sharing class HCPForgotPasswordServiceTest {

    public static testmethod void  testapi() {
        RestRequest req = new RestRequest();
        String str = '{"FirstName": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/ResetPassword';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPForgotPasswordService.resetPassword();
    }

    public static testmethod void  testapi2() {
        RestRequest req = new RestRequest();
        String str = '{"email": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/ResetPassword';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPForgotPasswordService.resetPassword();
    }
    public static testmethod void  testapi3() {
        Test.startTest();
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'vmopidevi+test9292920@salesforce.com';
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
        insert usr;
        Test.stopTest();
       // System.assert(false, JSON.serialize([SELECT Id FROM User WHERE Email='vmopidevi+test9292920@salesforce.com']));
        RestRequest req = new RestRequest();
        String str = '{"email": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/ResetPassword';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPForgotPasswordService.resetPassword();
        
    }

    public static testmethod void  testapi4() {
       
        HCPUSerRegistrationController.InputDataWrapper wrapper = new  HCPUSerRegistrationController.InputDataWrapper();
        
        wrapper.emailaddress = 'vmopidevi+test9292920@salesforce.com';
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
        insert usr;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            HCPUserMapping__mdt userMapping = [SELECT Id, Permission_Set_Name__c FROM HCPUserMapping__mdt WHERE Country__c ='Germany'];
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name =: userMapping.Permission_Set_Name__c];
            insert new PermissionSetAssignment(AssigneeId = usr.Id, PermissionSetId = ps.Id);
        }
        
        Test.stopTest();
       // System.assert(false, JSON.serialize([SELECT Id FROM User WHERE Email='vmopidevi+test9292920@salesforce.com']));
        RestRequest req = new RestRequest();
        String str = '{"email": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/ResetPassword';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPForgotPasswordService.resetPassword();
        
    }
}