/*****************************************************************
Name: HCPInflightRegBatch
============================================================
Purpose: 
    * There are existing registrations which are email verified and not validated in the system.
    * There are two kinds of users: IQVIA and NON IQVIA
    * IQVIA Contacts: Germany and Mexico Markets
        * Email Verified = True 
        * BrandName = Gainconnect 
        * Mailing Country = Other 8 Markets( 18 Countries , UAE has multiple countries)  
        * Trustlevel = Process Manually 
        * IsTest = False 
        * CIAMID = NOT Empty
        * IsActive = FALSE
    * NON IQVIA Contacts: Remaining all Markets
        * Email Verified = True 
        * BrandName = Gainconnect 
        * Trustlevel = Unknown OR Partially Trusted
        * Mailing Country = Germany Or Mexico 
        * IsTest = False 
        * isActive=FLASE
        * CIAMID = NOT Empty
User Story: GAIN-556
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Vamsi Krishna   Jan 23, 2024  Created
Database.executeBatch(new HCPInflightRegBatch(), 1);
Database.executeBatch(new HCPInflightRegBatch('(IsEmailVerified__c = TRUE AND BrandName__c INCLUDES (\'GainConnect \') AND IsTest__c = FALSE AND CIAMID__C != NULL) AND (TrustLevel__c IN (\'Unknown\', \'PartiallyTrusted\'))'), 1);
*****************************************************************/
public with sharing class HCPInflightRegBatch implements Database.Batchable<SObject>, Database.Stateful{
    public final Set<String> IQVIA_MARKETS = new Set<String> {
        'Germany', 'Mexico'
    };
    public final Set<String> NON_IQVIA_MARKETS = new Set<String> {
        'Colombia', 'Singapore', 'Brazil', 'Chile', 'Taiwan', 'South Africa',  'Taiwan', 'Thailand',
        'Bahrain', 'Egypt', 'Iraq', 'Jordan', 'Kuwait', 'Lebanon', 'Oman', 'Qatar', 'Saudi Arabia', 'UAE'

    };
    public Database.DMLOptions dmlOptions= getDmlOptionsForTriggeringCaseAssignmentRules();
    public Map<String, HCPUserMapping__mdt> userLocaleMap = new Map<String, HCPUserMapping__mdt>();
	public Id profileId = null;
    public String dynamicWhereCondition = '';

    public HCPInflightRegBatch() {
        
    }
    public HCPInflightRegBatch(String dynamicWhereCondition) {
        this.dynamicWhereCondition = dynamicWhereCondition;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        if(!FeatureManagement.checkPermission('Skip_Triggers_Flows') && !Test.isRunningTest()) {
			throw new CDCConsentDataUpdateBatch.CDCBatchException('User doesnt have the Skip_Triggers_Flows Permission Set. Please assign Skip_Triggerd_Flows PS to run this batch');
		}
        //Locale Mapping Logic
		for(HCPUserMapping__mdt mdtRec : HCPUserMapping__mdt.getAll().values()) {
			userLocaleMap.put(mdtRec.Country__c, mdtRec);
		}
		Profile hcpProfile = [SELECT Id FROM Profile WHERE Name =: System.Label.HCPSiteProfileName];
		profileId = hcpProfile.Id;

        String commonWhereCond = '(IsEmailVerified__c = TRUE AND BrandName__c INCLUDES (\'GainConnect \') AND IsTest__c = FALSE AND CIAMID__C != NULL)';
        String iqviaWhere = '(TrustLevel__c IN (\'Unknown\', \'PartiallyTrusted\') AND MailingCountry IN : IQVIA_MARKETS)';
        String nonIqviaWhere = '(TrustLevel__c IN (\'ProcessManually\') AND MailingCountry IN : NON_IQVIA_MARKETS)';
        String selectQuery = 'SELECT Id, MailingCountry, TrustLevel__c, FirstName, LastName, AccountId, Latest_Brand_Name__c, BrandName__c,Email,HasOptedOutOfEmail,Name, Phone, MailingPostalCode, NPIId__c, PrivacyConsent__c, Profession__c, MailingStreet, MiddleName, Business_Entity_Name__c, Title, MailingCity, EducationConsent__c, CIAMId__c,  ';
        String innerQueries = '(SELECT Id, RecordType.Name, Status, OwnerId, Owner.Name FROM Cases WHERE RecordType.Name != \'HCP Validation\'), (SELECT Id FROM Users) ';
        String combinedWhere = '(' + iqviaWhere + ' OR ' + nonIqviaWhere + ')';

        String query = selectQuery + innerQueries + ' FROM Contact WHERE ' + (String.isBlank(dynamicWhereCondition) ? (commonWhereCond + ' AND ' + combinedWhere) : dynamicWhereCondition);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> contacts) {
        //Contacts
        //IQVIA Market - Update the status to Process Manually
        List<Contact> updateContacts = new List<Contact>();
        List<Case> cases = new List<Case>();
        List<User> users = new List<User>();
        for(Contact con : contacts) {
            if(IQVIA_MARKETS.contains(con.MailingCountry)) {
                con.TrustLevel__c = 'ProcessManually';
                updateContacts.add(con);
            }
            // //Check if there is any existing case or not
            // if(con.Cases.isEmpty()) {
            //     //Create a new case
            //     cases.add(ContactService.createCase(con, dmlOptions, false));
            // } 
            // else {
            //     //Update the case - to fire the assignment rule;
            //     cases.add(con.Cases[0]);
            // }
            
            //create users - inactive - these users should be activated during the migration
            //Set migrated user = TRUE
            if(con.Users.isEmpty()) {
                cases.add(ContactService.createCase(con, dmlOptions, false));
                HCPUserMapping__mdt localeInfo = userLocaleMap.get(con.MailingCountry);
                HCPUserMigrationBatch obj = new HCPUserMigrationBatch();
                User usrRec = obj.getUserRecord(localeInfo, con, profileId);
                usrRec.IsActive = true;
                users.add(usrRec);
            }

        }
        if(!updateContacts.isEmpty()) {
            update updateContacts;
        }
        if(!cases.isEmpty()) {
            upsert cases;
        }
        if(!users.isEmpty() && !Test.isRunningtest()) {
            insert users;
        }
        
        


    }
    public void finish(Database.BatchableContext bc) {
        /**
         HCPInflightRegBatch batch = new HCPInflightRegBatch();
         Database.executeBatch( new HCPInflightRegBatch(), 10);
         */
    }

    public Database.DMLOptions getDmlOptionsForTriggeringCaseAssignmentRules() {
        AssignmentRule AR = [SELECT Id
               FROM AssignmentRule
               WHERE SobjectType = 'Case'
                 AND Active = true
               LIMIT 1];
        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
        dmlOpts.EmailHeader.triggerUserEmail = false;
        return dmlOpts;
    }
}