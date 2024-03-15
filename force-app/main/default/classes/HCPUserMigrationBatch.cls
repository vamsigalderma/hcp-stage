/*****************************************************************
Name: HCPUserMigrationBatch
============================================================
Purpose: Creates the site users for the migrated users from CDC.
User Story: GAIN-27
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Vamsi Krishna   Jan 23, 2024  Created
Database.executeBatch(new HCPUserMigrationBatch('Email = \'vmopidevi@salesasasaforce.com\''), 1);
Database.executeBatch(new HCPUserMigrationBatch(), 50);
*****************************************************************/
public without sharing class HCPUserMigrationBatch implements Database.Batchable<SObject>, Database.Stateful{
    public List<String> contactFields = new List<String> {
        'Id',
        'Email',
        'FirstName',
        'HasOptedOutOfEmail',
        'LastName',
        'Name',
        'Phone',
        'BrandName__c',
        'CIAMId__c',
        //'CPF__c',
        'MailingCountry',
        'MailingPostalCode',
        'NPIId__c',
        'PrivacyConsent__c',
        'Profession__c',
        'MailingStreet',
        'MiddleName',
        'Business_Entity_Name__c',
        'Title',
        'MailingCity',
        'EducationConsent__c'
    };
    public String whereCondition = '';
    public Map<String, HCPUserMapping__mdt> userLocaleMap = new Map<String, HCPUserMapping__mdt>();
    public Id profileId = null;
    public HCPUserMigrationBatch(String whereCondition) {
        this.whereCondition = whereCondition;
    }
    public HCPUserMigrationBatch() {
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!FeatureManagement.checkPermission('Skip_Triggers_Flows') && !Test.isRunningTest()) {
            throw new CDCConsentDataUpdateBatch.CDCBatchException('User doesnt have the Skip_Triggers_Flows Permission Set. Please assign Skip_Triggerd_Flows PS to run this batch');
        }
        String contactFieldsString = String.join(contactFields, ',');
        String innerQuery = ' (SELECT Id FROM Users) ';
        whereCondition = String.isBlank(whereCondition) ? 'CIAMID__c != NULL AND TrustLevel__c IN (\'FullyTrusted\') AND BrandName__c INCLUDES(\'GainConnect\') AND IsActive__c = TRUE AND IsTest__c = FALSE AND Id NOT IN (SELECT ContactId FROM User WHERE ContactId != NULL)' : whereCondition;
        String query = 'SELECT ' + contactFieldsString + ', ' + innerQuery + ' FROM Contact  WHERE ' + whereCondition;

        //Locale Mapping Logic
        for(HCPUserMapping__mdt mdtRec : HCPUserMapping__mdt.getAll().values()) {
            userLocaleMap.put(mdtRec.Country__c, mdtRec);
        }
        Profile hcpProfile = [SELECT Id FROM Profile WHERE Name =: System.Label.HCPSiteProfileName];
        profileId = hcpProfile.Id;
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        List<User> users = new List<User>();
        
        for(Contact con : contacts) {
            //Site user is not available for the customer
            if(con.users.isEmpty()) {
                HCPUserMapping__mdt localeInfo = userLocaleMap.get(con.MailingCountry);
                users.add(getUserRecord(localeInfo, con, profileId));
            }
        }
        if(!users.isEmpty()) {
            Database.insert(users, false);
        }
    }

    public void finish(Database.BatchableContext  bc) {

    }

    public User getUserRecord(HCPUserMapping__mdt localeInfo, Contact con, Id gainConnectProfileId) {
        
        String cleanedName =  (con.LastName).replaceAll('\\s+', '').toLowerCase();
        String uniqueName = cleanedName + String.valueOf(System.currentTimeMillis());
        User userRec = new User();
        userRec.ContactId = con.Id;
        userRec.FirstName = con.FirstName;
        userRec.LastName = con.LastName;
        userRec.Email = con.Email;
        userRec.Alias = uniqueName.abbreviate(8); // only 8 characters
        userRec.Username = con.Email;
        userRec.CommunityNickname = uniqueName.abbreviate(40);
        userRec.LocaleSidKey = localeInfo != null ? localeInfo.LocaleSidKey__c : 'en_US';
        userRec.TimeZoneSidKey = localeInfo != null ? localeInfo.TimeZoneSidKey__c : 'Europe/London';
        userRec.profileId = gainConnectProfileId;
        userRec.LanguageLocaleKey = localeInfo != null ? localeInfo.LanguageLocaleKey__c : 'en_US';
        userRec.EmailEncodingKey = 'UTF-8';
        userRec.ContactId = con.Id;
        userRec.IsActive = false;
        //Fields to be copied from Contact
        userRec.Profession__c = con.Profession__c;
        userRec.HasEmailOptedOut__c = con.HasOptedOutOfEmail;
        userRec.CIAMId__c = con.CIAMId__c;
        userRec.Country = con.MailingCountry;
        userRec.PrivacyConsent__c = con.PrivacyConsent__c;
        userRec.MedicalId__c = con.NPIId__c;
        userRec.MigratedFromCDC__c = TRUE;
        userRec.Street = con.MailingStreet;

        userRec.MiddleName = con.MiddleName;
        userRec.CompanyName = con.Business_Entity_Name__c;
        userRec.Title = con.Title;
        userRec.City = con.MailingCity;
        userRec.PostalCode = con.MailingPostalCode;
        userRec.FederationIdentifier = con.Email;
        userRec.EducationConsent__c = con.EducationConsent__c;
        userRec.Phone = con.Phone;
        return userRec;
    }
}