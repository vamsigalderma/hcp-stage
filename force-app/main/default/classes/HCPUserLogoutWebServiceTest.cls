@isTest
public with sharing class HCPUserLogoutWebServiceTest {
    public static testmethod void testapi() {
        RestRequest req = new RestRequest();
        String str = '{"email": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/UserLogout';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPUserLogoutWebService.doLogout();
    }
    public static testmethod void testapi2() {
        RestRequest req = new RestRequest();
        String str = '{"email2": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/UserLogout';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPUserLogoutWebService.doLogout();
    }
    public static testmethod void testapi3() {
        RestRequest req = new RestRequest();
        String str = '{"email2": "vmopidevi+test9292920@salesforce.com"}';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/UserLogout';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPUserLogoutWebService.doLogout();
    }
    public static testmethod void testapi4() {
        RestRequest req = new RestRequest();
        String str = '{"email2": "vmopidevi+test9292920@salesforce.com"';
        req.requestBody = Blob.valueof(str);
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/GainConnect/UserLogout';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        HCPUserLogoutWebService.doLogout();
    }
}