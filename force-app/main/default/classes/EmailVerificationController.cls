public without sharing class EmailVerificationController {
    
    // Returning errorCode if proper contact found '0' else '1'
     @AuraEnabled
     Public static Integer updateContactRecord(String emailVerificationKey){
        Integer errorCode;
        //to get contact for verification based on key
        try{
        List<Contact> contacts = [
            SELECT 
                Id,
                EmailVerificationKey__c,
                VerificationLinkExpiryDateTime__c,
                isEmailVerified__c
            FROM Contact 
            WHERE EmailVerificationKey__c=:emailVerificationKey 
AND EmailVerificationKey__c != NULL
            LIMIT 1];
        if(contacts.isEmpty()){
            return errorCode = 1;
        }else{
            Contact con = contacts[0];
            if(con.VerificationLinkExpiryDateTime__c >= System.now() && !con.isEmailVerified__c){ 
                con.isEmailVerified__c = true;
                con.EmailVerificationDatetime__c = System.now();
                update con;
                return errorCode =  0;
           }else  {
                return errorCode = 1;
           }
        }
        }catch (Exception e) {
            return errorCode = 1;
        }
    }

}