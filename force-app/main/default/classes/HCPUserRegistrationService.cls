/*****************************************************************
Name: HCPUserRegistrationService
============================================================
Purpose: This class contains methods used for email verification in all the user registration pages.
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Anka Ganta   Nov 29, 2023  Created
*****************************************************************/
public without sharing class HCPUserRegistrationService {
   
     //added for Email Verification Key generation
     @InvocableMethod(label='Get Email Verification Key')    
     public static List<Contact> populateEmailVerificationKey(List<Contact> newList) { 
        List<Contact> contactListToUpdate = new List<Contact>();
          for (Contact triggeredContact : newList) {
            System.debug('newList--'+newList);
            if(triggeredContact.EmailVerificationKey__c == null){
             Blob b = Crypto.GenerateAESKey(128);
             String h = EncodingUtil.ConvertTohex(b);
             String currenttimestampString = String.valueof(DateTime.now().getTime());
             String emailVerificationKey = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20)
             + '-' + currenttimestampString + '-' + String.valueOf(Math.random()).right(5);
             triggeredContact.EmailVerificationKey__c = emailVerificationKey;
             contactListToUpdate.add(triggeredContact);
          }
         
       }
       return contactListToUpdate;
    }

    
}