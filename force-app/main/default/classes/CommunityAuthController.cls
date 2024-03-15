public without sharing class CommunityAuthController {
    public CommunityAuthController() {

    }

    @AuraEnabled
    public static string doLogin(String username, String password, String startUrl){
        String errorMessage = '';
        try {
            
            //String startUrl = System.Label.Community_Url;
            List<User> userRecords = [SELECT Id, Contact.PrivacyConsent__c FROM User WHERE Username =:  username AND ContactId != null];
            if(!userRecords.isEmpty() && !userRecords[0].Contact.PrivacyConsent__c) {
                errorMessage = 'Privacy Consent is not available. Please contact your administrator';
                throw new AuraHandledException(errorMessage);
            }
            ApexPages.PageReference pageRef = Site.login(username, password, startUrl);

            if(pageRef != null) {
                return pageRef.getUrl();
            }
            else {
                throw new CalloutException();
            }


        } catch (Exception e) {
            system.debug('e.getMessagelogin+   '+e.getMessage());
            throw new AuraHandledException(String.isNotBlank(errorMessage) ? errorMessage : e.getMessage());

           
        }
        //return null;
    }

    @AuraEnabled
    public static String checkMigratedUser(String emailAddress){
        String validationResult = null;
        try {
            List<User> users = [SELECT Id, Contact.IsEmailVerified__c,IsPasswordChanged__c, MigratedFromCDC__c,
             (SELECT Id FROM PermissionSetAssignments WHERE PermissionSet.Name LIKE '%Access') 
             FROM User WHERE (UserName=: emailAddress AND IsActive = TRUE AND ContactId != NULL) LIMIT 1 ];
            List<Contact> contacts = [SELECT Id, IsEmailVerified__c FROM Contact WHERE Email =: emailAddress LIMIT 1];
            if(!users.isEmpty() && !users[0].PermissionSetAssignments.isEmpty() && !users[0].IsPasswordChanged__c && users[0].MigratedFromCDC__c){
                validationResult = 'MigratedUser';
            }else if((!users.isEmpty() && !users[0].Contact.IsEmailVerified__c) || (!contacts.isEmpty() && !contacts[0].IsEmailVerified__c)){
                validationResult = 'UserNotVerified';
            }else if(!users.isEmpty() && users[0].Contact.IsEmailVerified__c == true 
                      && users[0].PermissionSetAssignments.isEmpty()){
                    validationResult = 'UserNotValidated';
            }
            
        } catch (Exception e) {

            throw new CalloutException();
        }
       return validationResult;
    }
}