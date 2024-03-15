@isTest
public with sharing class HCPChangePasswordControllerTest {
    

    public static testmethod void test1() {
        try {
            PageReference thePage = Page.HCPChangePassword;
            thePage.getParameters().put('email', 'vamsikrishna.mopidevi@galderma.com');
            Test.setCurrentPage(thePage);
            HCPChangePasswordController hcp = new HCPChangePasswordController();
        }
        catch(Exception e) {
            
        }
        
    }
}