/*****************************************************************
Name: HCPResendVerificationEmail
============================================================
Purpose: This class contains methods to resend verification email in all the user registration pages.
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Anka Ganta   Dec 19, 2023  Created
*****************************************************************/
@RestResource(urlMapping='/GainConnect/resendEmailVerification')
global with sharing class HCPResendVerificationEmail {
    @HttpPost
    global static Map<String, Integer> sendVerificationLink() {
        Map<String, Integer> responseMap = new Map<String, Integer>();
        RestRequest request = RestContext.request;
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
        String email = requestMap.containsKey('email') ? String.valueOf(requestMap.get('email')): '';
        //Boolean sendEmail = Boolean.valueOf(requestMap.get('sendEmail'));
        Boolean sendEmail = !Test.isRunningTest() ? Boolean.valueOf(requestMap.get('sendEmail')): true;
        List<Contact> con = [
            SELECT 
                Id,
                EmailVerificationKey__c,
                VerificationLinkExpiryDateTime__c,
                isEmailVerified__c,
                isVerificationEmailSent__c,
                Email,
                Account.Id
            FROM Contact 
            WHERE Email =:email
            ORDER BY LastModifiedDate DESC NULLS LAST 
            LIMIT 1
        ];
        if(con.size() > 0 && !sendEmail) {
            responseMap.put('errorCode' , 0);
        }
        else if(!con.isEmpty() && con[0].isEmailVerified__c) {
            responseMap.put('errorCode' , 1);
        }
        else if(con.size() > 0) {
            
            //If contact is found & Verification time is not expired(active)
            List<Task> tasks = [
                SELECT 
                    Id, TaskSubtype 
                FROM Task 
                WHERE WhoId =: con[0].Id 
                    AND TaskSubtype = 'Email'
            ];
            if(!tasks.isEmpty()) {
                DateTime lastTwoHours = DateTime.now().addhours(-2);
                List<EmailMessage> emailMessages = [
                    SELECT 
                        Id 
                    FROM EmailMessage 
                    WHERE ActivityId IN : tasks 
                    AND EmailTemplate.DeveloperName = 'Experience_Cloud_HCP_Email_Verification'
                    AND CreatedDate > :lastTwoHours
                    AND CreatedBy.Name IN ('Portal Integration', 'Drupal Integration')
                ];
                if(emailMessages.size() >= 10) {
                    responseMap.put('errorCode' , 1);
                    return responseMap;
                }
            }
            if(con[0].VerificationLinkExpiryDateTime__c >= System.now() 
                && sendEmail){ 

                Boolean isSuccess = resendEmailVerification(con[0]);
                responseMap.put('errorCode' , isSuccess ? 0 : 1);
            }
            //If contact is found & Verification time is expired 
            else if(con[0].VerificationLinkExpiryDateTime__c == null || (con[0].VerificationLinkExpiryDateTime__c < System.now()) 
                    && sendEmail) {
                
                Boolean isSuccess = resendEmailVerification(con[0]);
                responseMap.put('errorCode' , isSuccess ? 0 : 1);
                con[0].VerificationLinkExpiryDateTime__c = System.now() + 7;
                con[0].EmailVerificationReminderCount__c = '0';
con[0].isVerificationEmailSent__c = true;
                con[0].Email_Verification_Sent_DateTime__c = System.now();
                update con[0];
            } else { // not sent verification email or No VerificationLinkExpiryDateTime
                 responseMap.put('errorCode' , 2);
            }
            
        } else {
            responseMap.put('errorCode' , 2);
        }
        return responseMap;
    }
    
   // method to sent verification email : Use the same template as initial verification link that was sent post registration
    public static Boolean resendEmailVerification(Contact contact){
        if(String.isBlank(contact.EmailVerificationKey__c)) {
            HCPUserRegistrationService.populateEmailVerificationKey(new List<Contact> {contact});
            update contact;
        }
        //Flag to track whether email is sent successfully
        Boolean isSuccess = false;
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address =:Label.HCPOrgWideEmailAddress];
        if ( owea.size() > 0 ) {
            message.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        message.setTargetObjectId(contact.id); 
       // message.setSenderDisplayName('Galderma Support'); 
        message.setReplyTo('noreply-gc@gainconnect.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(true); 
       EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = 'Experience_Cloud_HCP_Email_Verification'];
       message.setTemplateID(emailTemplate.Id); 
       message.setWhatId(contact.account.Id); //This is important for the merge fields in template to work
       message.toAddresses = new String[] { contact.email};
       Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
       try{
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if(results[0].success){
                isSuccess = true;
                System.debug('The email was sent successfully.');
            }else{
                isSuccess = false;
            }
        } catch(Exception ex){
            isSuccess = false;
            System.debug(LoggingLevel.ERROR, 'Error occurred while sending the email. errorMessage - ' + ex.getMessage() + 'at Line Number' + ex.getLineNumber());
            throw new AuraHandledException(ex.getMessage());
        }
      return isSuccess;
    }
    
}