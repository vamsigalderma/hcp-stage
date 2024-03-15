/*****************************************************************
Name: HCPUSerRegistrationController
============================================================
Purpose: This class contains methods used in all the user registration pages.
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Vamsi Krishna   Nov 03, 2023  Created
*****************************************************************/
public without sharing class HCPUSerRegistrationController {
    //This method is used to check whether the given email address is duplicate or not in salesforce.
    @AuraEnabled(cacheable = true)
    public static Boolean checkDuplicateContacts(String emailAddress, String country) {
        List<Contact> duplicateContacts = [
            SELECT
                Id
            FROM Contact
            WHERE Email =: emailAddress
            AND BrandName__c INCLUDES ('GainConnect')
            LIMIT 1
        ];
        return duplicateContacts.size() > 0;
    }
    //This method is used to get the picklist values(Translated based on the site language) of the fields. 
    @AuraEnabled(cacheable = true)
    public static Map<String, object> getPicklistValues() {
        //get the prefix of the site. eg: br, de, ae
        String sitePathPrefix = Test.isRunningTest() ? 'de' : Site.getPathPrefix().replace('/','');
        Map<String, Object>  fieldToValuesMapping = new Map<String, Object>();
        //query the picklists based on the country
        List<HCP_Country_Picklist_Mapping__mdt> languageMappings = [
            SELECT 
                Id, 
                Field_API_Name__c, 
                Picklist_Values__c 
            FROM HCP_Country_Picklist_Mapping__mdt 
            WHERE Language__c =: sitePathPrefix
        ];
       //logic to get the picklist values
        Map<String,Schema.SObjectField> fields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        for(HCP_Country_Picklist_Mapping__mdt mapping  : languageMappings) {
            List<SerilizableSelectOption> options = new List<SerilizableSelectOption>();
            List<String> tempPicklists = (mapping.Picklist_Values__c).split(';');
            Set<String> availablePicklistValues =  new Set<String>(tempPicklists);
            List<Schema.PicklistEntry> ple = fields.get(mapping.Field_API_Name__c).getDescribe().getPicklistValues();
            //first value is the default picklist value.
            fieldToValuesMapping.put(mapping.Field_API_Name__c + 'Default', tempPicklists[0]);
            Map<String, Schema.PicklistEntry> picklistEntryMap = new Map<String, Schema.PicklistEntry>();
            for(Schema.PicklistEntry pickListVal : ple) {
                picklistEntryMap.put(pickListVal.getValue(), pickListVal);
            }
            for(String pickValue : availablePicklistValues) {
                if(picklistEntryMap.containsKey(pickValue)) {
                    options.add(new SerilizableSelectOption(picklistEntryMap.get(pickValue)));
                }
            }
            fieldToValuesMapping.put(mapping.Field_API_Name__c, options);

        }


        return fieldToValuesMapping;

    }

    //This method is used to submit the form data.
    //Creates the contact.(Indiviudual and Consent related data is created based on the contact details using Auto Launched Flows.)
    @AuraEnabled
    public static  String submitRegistration(InputDataWrapper wrapper) {
        String returnMessage = '';
        Savepoint sp = Database.setSavepoint();
        try {

            Contact contactRec = getContactRecord(wrapper);
            insert contactRec;
            //User Mapping
            List<Contact> accounts = [SELECT Id, Accountid FROM Contact WHERE Id =: contactRec.Id];
            User userRec = getUserRecord(contactRec, wrapper);
            Site.createExternalUser(userRec,accounts[0].AccountId, String.isBlank(wrapper.password) ? 'Test1@11' : wrapper.password, false);
            returnMessage = 'Success';
        }
        catch(Exception e) {
            Database.rollback(sp);
            returnMessage = 'Error Occurred: ' + e.getMessage();
        }
        
        return returnMessage;
    }
    
    public static Id ContentVersionId;
   
    @AuraEnabled
    public static Map<String,String> submitRegistrationBrazil(InputDataWrapper wrapper) {
        String returnMessage = '';
        Map<String,String> returnMap = new Map<String,String>();
        Savepoint sp = Database.setSavepoint();
        try {
            Contact contactRec = getContactRecord(wrapper);
            insert contactRec;
            List<Contact> accounts = [SELECT Id, Accountid, Owner.Name FROM Contact WHERE Id =: contactRec.Id];
            System.debug(' Owner.Name ++' +  accounts[0].Owner.Name);
            User userRec = getUserRecord(contactRec, wrapper);
            Site.createExternalUser(userRec,accounts[0].AccountId, wrapper.password, false);
            returnMessage = 'Success';
            returnMap.put(returnMessage,String.valueOf(contactRec.Id));
        }
        catch(Exception e) {
            Database.rollback(sp);
            returnMessage = 'Error Occurred: ' + e.getMessage();
            returnMap.put(returnMessage,null);
        }
        
        return returnMap;
    }

    //contact data mapping
    public static Contact getContactRecord(InputDataWrapper wrapper) {
        Contact contactRec = new Contact();
        contactRec.FirstName = wrapper.firstname;
        contactRec.LastName = wrapper.lastname;
        contactRec.MiddleName = wrapper.middlename;
        contactRec.Title = wrapper.title;
        contactRec.Email = wrapper.emailaddress;
        contactRec.Profession__c = wrapper.profession;
        contactRec.NPIId__c = wrapper.medicalid;
        contactRec.Business_Entity_Name__c = wrapper.organization;
        contactRec.Phone = wrapper.phone;
        contactRec.MailingStreet = wrapper.address;
        contactRec.MailingState = wrapper.state;
        contactRec.MailingPostalCode = wrapper.zipcode;
        contactRec.MailingCity = wrapper.city;
        contactRec.Gender__c = wrapper.gender;
        contactRec.MailingCountry =   wrapper.country != null ?  wrapper.country : System.Label.HCPSiteCountry;
        ContactService.setPhoneNumberInCorrectFormat(new List<Contact>{contactRec}, null);
        contactRec.BrandName__c = 'GainConnect';
        contactRec.LeadSource = 'GainConnect/Website';
        contactRec.PreferredLanguage__c =  System.Label.HCPPreferredLanguage;
        contactRec.BirthDate = wrapper.dateOfBirth;
        contactRec.CPF__c = wrapper.cpf;
        contactRec.Council_State__c = wrapper.councilState;
        contactRec.Specialty__c = wrapper.specialty;
        contactRec.isEmailVerified__c = TRUE;
        //Marketing Consent
        Boolean makretingConsent = wrapper.marketingconsent != null ? wrapper.marketingconsent : false;
        contactRec.put('HasOptedOutOfEmail', !makretingConsent);
        contactRec.put('et4ae5__HasOptedOutOfMobile__c', !makretingConsent);
        //Licensing Consent
        contactRec.put('LicenseAgreementConsent__c', wrapper.licensingconsent != null ? wrapper.licensingconsent : false);
        //Privacy Consent
        contactRec.put('PrivacyConsent__c', wrapper.privacyconsent != null ? wrapper.privacyconsent : false);
        if(contactRec.MailingCountry == 'Brazil') {
            contactRec.put('HasOptedOutOfEmail',  wrapper.privacyconsent != null ? !wrapper.privacyconsent : true);
            contactRec.put('et4ae5__HasOptedOutOfMobile__c',  wrapper.privacyconsent != null ? !wrapper.privacyconsent : true);
        }
        //Education Consent
        if(contactRec.MailingCountry != null && contactRec.MailingCountry == 'Thailand'){
        contactRec.put('EducationConsent__c', wrapper.educationconsent != null ? wrapper.educationconsent : false);
        }
        return contactRec;
    }
    //User data mapping
    public static User getUserRecord(Contact contactRec, InputDataWrapper wrapper) {
        Profile hcpProfile = [SELECT Id FROM Profile WHERE Name =: System.Label.HCPSiteProfileName];
        Map<String, HCPUserMapping__mdt> userLocaleMap = new  Map<String, HCPUserMapping__mdt>();
        for(HCPUserMapping__mdt mdtRec : HCPUserMapping__mdt.getAll().values()) {
            userLocaleMap.put(mdtRec.Country__c, mdtRec);
        }
        HCPUserMapping__mdt localeInfo = userLocaleMap.get(contactRec.MailingCountry);
        String cleanedName =  (contactRec.FirstName + contactRec.LastName).replaceAll('\\s+', '').toLowerCase();
        String uniqueName = cleanedName + String.valueOf(System.currentTimeMillis());
        User userRec = new User();
        userRec.FirstName = contactRec.FirstName;
        userRec.LastName = contactRec.LastName;
        userRec.Email = contactRec.Email;
        userRec.Alias = (contactRec.FirstName).left(1) + (contactRec.LastName).left(4);//uniqueName.abbreviate(8); // only 8 characters
        userRec.Username = contactRec.Email;
        userRec.CommunityNickname = uniqueName.abbreviate(40);
        userRec.LocaleSidKey = localeInfo != null ? localeInfo.LocaleSidKey__c : 'en_US';
        userRec.TimeZoneSidKey = localeInfo != null ? localeInfo.TimeZoneSidKey__c : 'Europe/London';
        userRec.profileId = hcpProfile.Id;
        userRec.LanguageLocaleKey = localeInfo != null ? localeInfo.LanguageLocaleKey__c : 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.ContactId = contactRec.Id;
        userRec.IsActive = true;
        //Fields to be copied from Contact
        userRec.Profession__c = contactRec.Profession__c;
        userRec.HasEmailOptedOut__c = contactRec.HasOptedOutOfEmail;
        //userRec.CIAMId__c = contactRec.CIAMId__c;
        userRec.Country = contactRec.MailingCountry;
        userRec.PrivacyConsent__c = contactRec.PrivacyConsent__c;
        userRec.MedicalId__c = contactRec.NPIId__c;
        userRec.ContactId = contactRec.Id;
        userRec.MiddleName = contactRec.MiddleName;
        userRec.Phone = contactRec.Phone;
        userRec.Street = contactRec.MailingStreet;
        userRec.PostalCode = contactRec.MailingPostalCode;
        userRec.CompanyName = contactRec.Business_Entity_Name__c;
        userRec.Title = contactRec.Title;
        userRec.City = contactRec.MailingCity;
        userRec.FederationIdentifier = contactRec.Email;
        userRec.LicenseAgreementConsent__c = contactRec.LicenseAgreementConsent__c;
        userRec.EducationConsent__c = contactRec.EducationConsent__c;
        return userRec;
    }
    //Wrapper class to hold picklist values
    public class SerilizableSelectOption {

        @AuraEnabled
        public String value {get; set;}
        @AuraEnabled
        public String label {get; set;}
        
        public SerilizableSelectOption(PicklistEntry pe) {
            this.value = pe.getValue();
            this.label = pe.getLabel();
        }
    }

    
    //Wrapper class to hold the form input values
    public class InputDataWrapper {
        @AuraEnabled
        public String emailaddress {get; set;}

        @AuraEnabled
        public String organization {get; set;}

        @AuraEnabled
        public String firstname {get; set;}

        @AuraEnabled
        public String lastname {get; set;}
        @AuraEnabled
        public String middlename {get; set;}
        @AuraEnabled
        public String zipcode {get; set;}

        @AuraEnabled
        public String state {get; set;}
        @AuraEnabled
        public String country {get; set;}
        @AuraEnabled
        public String city {get; set;}

        @AuraEnabled
        public String gender {get; set;}

        @AuraEnabled
        public String address {get; set;}

        @AuraEnabled
        public String medicalid {get; set;}

        @AuraEnabled
        public String phone {get; set;}

        @AuraEnabled
        public String profession {get; set;}

        @AuraEnabled
        public String title {get; set;}

        @AuraEnabled
        public Boolean privacyconsent {get; set;}

        @AuraEnabled
        public Boolean marketingconsent {get; set;}

        @AuraEnabled
        public Boolean licensingconsent {get; set;}
        @AuraEnabled
        public Boolean educationconsent {get; set;}
        @AuraEnabled
        public Date dateOfBirth {get; set;}
        @AuraEnabled
        public String cpf {get; set;}
        @AuraEnabled  
        public String councilState {get; set;}
        @AuraEnabled
        public String specialty {get; set;}
        @AuraEnabled
        public String confirmpassword {get; set;}
        @AuraEnabled
        public String password {get; set;}
    }

@AuraEnabled
  public static String uploadFile(String base64, String filename, String recordId,String fileType) {
       String resultMessage;
       //System.debug('filedata'+base64 + ' '+filename + ' '+ recordId);
        Savepoint sp = Database.setSavepoint();
        try {
            ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        resultMessage =  cv != null && cdl != null ? 'Success'+ fileType: 'Error';
        }catch(Exception e) {
            Database.rollback(sp);
            resultMessage = 'Error Occurred: ' + e.getMessage();
        }

        return resultMessage;
  }
  private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        cv.Description = 'License';
        try {
          insert cv;
          return cv;
        } catch(DMLException e) {
          System.debug(e);
          return null;
        }
      }
      private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion 
            WHERE Id =: contentVersionId].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
            try {
            insert cdl;
            return cdl;
            } catch(DMLException e) {
            System.debug(e);
            return null;
            }
            }
}