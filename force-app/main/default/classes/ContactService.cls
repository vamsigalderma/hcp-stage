/*******************************************************************************************
* @Name         ContactTriggerHandler
* @Author       Vamsi Krishna
* @Description  This is the trigger service for Contact records.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer                Date               Description
*-------------------------------------------------------------------------------------------
*  1.0            Vamsi Krishna Mopidevi    08/11/2023         Initial Creation.Moved the code from Handler class to Service Class.
*******************************************************************************************/
public without sharing class ContactService {

    //used to skip the duplicate rules when we insert a new contact using API.(HCPCreateContactFromGainconnect)
    public static Boolean SKIP_DUPLICATE_RULE = FALSE;

    public static void contactandAccountcreationandupdate(List<contact> listcon){

        List<String> clinicNamesList = new List<String>();
        Map<String, String> accountClinicalNameMap= new Map<String, String>();
        List<Account> accountsListToInsert = new List<Account>();
        List<Contact> lstContacts = new List<Contact>();
        
        for(Contact Con : listcon){
            if(con.Business_Entity_Name__c != null){
                clinicNamesList.add(con.Business_Entity_Name__c);  
            }
            else{
                clinicNamesList.add(con.FirstName + ' ' + con.LastName);
            }
        }

        if(!clinicNamesList.isEmpty()){
            for(Account accObj : [select Id, Name FROM Account WHERE Name IN : clinicNamesList])
            {
                accountClinicalNameMap.put(accObj.Name, accObj.Id);  
            }
        }

        for(Contact Con : listcon){
            if(con.Business_Entity_Name__c != null && accountClinicalNameMap != null && accountClinicalNameMap.containsKey(con.Business_Entity_Name__c)){
                con.AccountId = accountClinicalNameMap.get(con.Business_Entity_Name__c);
            }
            else if(con.Business_Entity_Name__c != null && !accountClinicalNameMap.containsKey(con.Business_Entity_Name__c)){
                Account acc = new Account();
                acc.Name = con.Business_Entity_Name__c;
                accountsListToInsert.add(acc);
                lstContacts.add(con);
            }
            else if(con.Business_Entity_Name__c == null && accountClinicalNameMap.containsKey(con.FirstName + ' ' + con.LastName) ){
                con.AccountId = accountClinicalNameMap.get(con.FirstName + ' ' + con.LastName);
            }
            else if(con.Business_Entity_Name__c == null && !accountClinicalNameMap.containsKey(con.FirstName + ' ' + con.LastName) ){
              //checking for firstname null condition
                string AccName;
                if(con.FirstName == null || con.FirstName == ''){
                    AccName = con.LastName;
                    system.debug(AccName);
                }else if(con.FirstName!=null || con.FirstName!=''){
                    AccName = con.FirstName +' '+ con.LastName;
                    system.debug(AccName);
                }
                Account acc= new Account();
                acc.Name = AccName;
                acc.ShippingCountry = con.MailingCountry;
                accountsListToInsert.add(acc); 
                
                lstContacts.add(con);
            }
            
        }
        if(!accountsListToInsert.isEmpty()){
            insert accountsListToInsert;
            for(Account acc :accountsListToInsert){
                for(Contact Con:lstContacts){
                    if(con.Business_Entity_Name__c!=null && con.Business_Entity_Name__c==acc.Name){
                       con.AccountId=acc.Id; 
                    }
                    if(con.Business_Entity_Name__c==null && con.FirstName+' '+con.LastName==acc.Name){
                       con.AccountId=acc.Id; 
                    }
                }
            }
        }
        
       /* 
        system.debug('===existingacclist===='+existingacclist);     
        if(!existingacclist.isEmpty()){
            for(Account Acc:existingacclist){
                existingaccMap.put(Acc.Name,Acc.Id);    
                
            }
        }
        system.debug('===existingaccMap===='+existingaccMap);
        if(!contactnamelist.isEmpty()){
            for(string str :contactnamelist) {
                Account newAcc = New Account();
                newAcc.Name=str;
                newaccList.add(newAcc);
            } 
            
        }
        if(!newaccList.isEmpty()){
            insert newaccList; 
            for(Account accnew :newaccList){
                existingaccMap.put(accnew.Name,accnew.Id);   
            }
            
        }
        system.debug('=====newaccList===='+newaccList);
        system.debug('=====existingaccMap===='+existingaccMap);
        List<contact> newcontactlist = new List<contact>();
        for(contact c:listcon){
            contact newcontact = new contact();
            if(existingaccMap.containskey(c.Business_Entity_Name__c))  {
                newcontact.AccountId=existingaccMap.get(c.Business_Entity_Name__c);
                newcontact.Email='test@gmail.com';
                newcontact.lastname='lastname';
                newcontactlist.add(newcontact); 
            }
            if(!existingaccMap.containskey(c.Business_Entity_Name__c)){
                newcontact.AccountId=existingaccMap.get(c.FirstName+c.lastname); 
                newcontact.Email='test@gmail.com';
                newcontact.lastname='lastname';
                newcontactlist.add(newcontact);
            }
        }
        if(!newcontactlist.isEmpty()){
            insert newcontactlist;
        }*/
    }
    /* @author - Vamsi Krishna Mopidevi
     * @methodName - createOrUpdateConsents
     * @description - This method is used to create consents on creation of a contact record. 
     * This logic is used for GainConnect User Registration pages and other brands also.
     * BrandName__c is a Multi Picklist. But, we will be having only one brand associated with contact
     * @User Story- GAIN - 29
     * Implementations Observations: 
     * ContactPointConsent is not related to Contact and Individual Id. It is a child of ContactPointEmails, ContactPointPhones. 
     * So we cant query all the child records using a single query. We have create a new lookup field on ContactPointConsent object to query all the child records .
     * ContactPointConsent:  ContactPointId is populated for Email and Phone. But it is blank license agreement.
     * Scenario 1: Creating a new contact record with consents as optout. Do we need to create consent records and mark them as consent optout.
     * Scenario 2: This code will not create consent point email or other conset records if there is no change in the consent fields on contact.
     * Q1: ConactPointConsent.ContactPoint is always required. Which value to use for License and Privacy consents.
     * ---------------------------------------------------------------------------------------------------------------------------------------
     * @lastmodifiedby- 
     * @lastmodifieddate - 
     * @purpose- 
    */
    public static void createOrUpdateConsents(List<Contact> newContactsList, Map<Id, Contact> oldMap) {
        Boolean isInsert = oldMap == null;
        Map<String, Boolean> recordCreationMap = new Map<String, Boolean>();
        List<Sobject> recordsToUpdate = new List<Sobject>();
        Map<Id, Individual> individuals = new Map<Id, Individual>();
        Map<Id, ContactPointEmail> contactPoinEmailMap = new Map<Id, ContactPointEmail>();
        Map<Id, ContactPointPhone> contactPointPhoneMap = new Map<Id, ContactPointPhone>();
        List<ContactPointConsent> consentsToInsert = new List<ContactPointConsent>();

        if(!isInsert) {
            Map<Id, Contact> indivToConMap = new Map<Id, Contact>();
            Map<Id, Boolean> changedEmailConsentMap = new Map<Id, Boolean>();
            Map<Id, Boolean> changedPhoneConsentMap = new Map<Id, Boolean>();
            Map<Id, Boolean> changedLicenseConsentMap = new Map<Id, Boolean>();
            Map<Id, Boolean> changedPrivacyConsentMap = new Map<Id, Boolean>();
            Map<Id, Boolean> changedEducationConsentMap = new Map<Id, Boolean>();
            for(Contact newCon : newContactsList) {
                if((String.isBlank(newCon.IndividualId) || newCon.BrandName__c != 'GainConnect') && Trigger.isExecuting) {
                    //create new Indiviudal Id Logic.
                    //Update the IndividualId on the contact record
                    //Logic to create individual records on insert and update logic is already available in before triggers.
                    continue;
                }
                Contact oldCon = oldMap.get(newCon.Id);
                //Mobile Consent Changes
                if(oldCon.et4ae5__HasOptedOutOfMobile__c != newCon.et4ae5__HasOptedOutOfMobile__c 
                    || (oldCon.Phone == null && String.isNotBlank(newCon.Phone))) {
                    changedPhoneConsentMap.put(newCon.IndividualId, newCon.et4ae5__HasOptedOutOfMobile__c);
                }
                //License Consent Changes
                if(oldCon.LicenseAgreementConsent__c != newCon.LicenseAgreementConsent__c) {
                    changedLicenseConsentMap.put(newCon.IndividualId, newCon.LicenseAgreementConsent__c);
                }
                //Email Consent Changes
                if(oldCon.HasOptedOutOfEmail != newCon.HasOptedOutOfEmail) {
                    changedEmailConsentMap.put(newCon.IndividualId, newCon.HasOptedOutOfEmail);
                    
                }
                //Privacy Consent Changes
                if(oldCon.PrivacyConsent__c != newCon.PrivacyConsent__c) {
                    changedPrivacyConsentMap.put(newCon.IndividualId, newCon.PrivacyConsent__c);
                    
                }
                //Education Consent Changes
                if(newCon.MailingCountry != null && newCon.MailingCountry == 'Thailand' && oldCon.EducationConsent__c != newCon.EducationConsent__c) {
                    changedEducationConsentMap.put(newCon.IndividualId, newCon.EducationConsent__c);
                    
                }
                indivToConMap.put(newCon.IndividualId, newCon);

            }

            individuals = new Map<Id, Individual>([
                SELECT
                    Id,
                    //Contact Point Email
                    (
                        SELECT
                            Id
                        FROM ContactPointEmails
                    ),
                    //Contact Point Phone
                    (
                        SELECT
                            Id
                        FROM ContactPointPhones
                    )
                    
                FROM Individual
                WHERE Id IN : indivToConMap.keySet()
            ]);

            Map<String, ContactPointConsent> typeToConsentMap = new Map<String, ContactPointConsent>();
            for(ContactPointConsent consent : [SELECT Id, Contact__r.IndividualId, ContactPointId, 
                                                DataUsePurpose.Name, EffectiveTo, EffectiveFrom FROM ContactPointConsent
                                                WHERE Contact__c IN : indivToConMap.values() AND DataUsePurposeId != NULL
                                                AND IsDuplicate__c = FALSE]) {
                
                //Create the map based on the data use purpose.
                String uniqueKey = consent.DataUsePurpose.Name != 'Marketing' ? consent.Contact__r.IndividualId + consent.DataUsePurpose.Name : consent.ContactPointId;
                typeToConsentMap.put(uniqueKey, consent);
            }
            
            for(Individual indiv : individuals.values()) {
                //Do we need to create a new ContactPointEmail record
                Boolean emailConsents = indiv.ContactPointEmails.isEmpty();
                recordCreationMap.put(indiv.Id + 'ContactPointEmail', emailConsents);
                //Do we need to create Consent record for ContactPointEmail
                recordCreationMap.put(indiv.Id + 'ContactPointEmailConsent', 
                    (emailConsents || !typeToConsentMap.containsKey(indiv.ContactPointEmails[0].Id)));
                //Do we need to create a new ContactPointPhone record
                Boolean phoneAvailable = indiv.ContactPointPhones.isEmpty();
                recordCreationMap.put(indiv.Id + 'ContactPointPhone', phoneAvailable);
                //Do we need to create Consent record for ContactPointPhone
                recordCreationMap.put(indiv.Id + 'ContactPointPhoneConsent', 
                    phoneAvailable || !typeToConsentMap.containsKey(indiv.ContactPointPhones[0].Id));
                //Do we need to create Consent record for License Agreement
                recordCreationMap.put(indiv.Id + 'License Agreement', !typeToConsentMap.containsKey(indiv.Id + 'License Agreement'));
                //Do we need to create Consent record for Privacy
                recordCreationMap.put(indiv.Id + 'Privacy', !typeToConsentMap.containsKey(indiv.Id + 'Privacy'));
                //Do we need to create Consent record for Education
                recordCreationMap.put(indiv.Id + 'Education', !typeToConsentMap.containsKey(indiv.Id + 'Education'));

                //Logic to Update the consent records if they are available
                //Check if there is a change in the Marketing Consent(Email and Phone) and License Agreement Consent
                if(!indiv.ContactPointEmails.isEmpty() && changedEmailConsentMap.containsKey(indiv.Id)){
                    getConsentRecord(typeToConsentMap, indiv.ContactPointEmails[0].Id, !changedEmailConsentMap.get(indiv.Id) , recordsToUpdate);
                }
                if(!indiv.ContactPointPhones.isEmpty() && changedPhoneConsentMap.containsKey(indiv.Id)){
                    getConsentRecord(typeToConsentMap, indiv.ContactPointPhones[0].Id, !changedPhoneConsentMap.get(indiv.Id) , recordsToUpdate);
                }
                //License Agreement
                if(changedLicenseConsentMap.containsKey(indiv.Id) && typeToConsentMap.containsKey(indiv.Id + 'License Agreement')){
                    getConsentRecord(typeToConsentMap, indiv.Id + 'License Agreement', changedLicenseConsentMap.get(indiv.Id) , recordsToUpdate);
                }

                //Privacy Agreement
                if(changedPrivacyConsentMap.containsKey(indiv.Id)  && typeToConsentMap.containsKey(indiv.Id + 'Privacy')){
                    getConsentRecord(typeToConsentMap, indiv.Id + 'Privacy', changedPrivacyConsentMap.get(indiv.Id) , recordsToUpdate);
                }
                //Education Agreement
                if(changedEducationConsentMap.containsKey(indiv.Id)  && typeToConsentMap.containsKey(indiv.Id + 'Education')){
                    getConsentRecord(typeToConsentMap, indiv.Id + 'Education', changedEducationConsentMap.get(indiv.Id) , recordsToUpdate);
                }
            }
            update recordsToUpdate;

        }

        
        for(Contact con : newContactsList) {
            if(con.BrandName__c != 'GainConnect' && Trigger.isExecuting) {
                continue;
            }
            //creation logic for Contact Point Email
            if(con.Email != null && (isInsert || recordCreationMap.get(con.IndividualId + 'ContactPointEmail'))) {
                ContactPointEmail cpe = new ContactPointEmail(
                    EmailAddress = con.Email,
                    IsPrimary =  true, 
                    ParentId = con.IndividualId,
                    ActiveFromDate = System.today()
                );
                contactPoinEmailMap.put(con.IndividualId, cpe);

            }
            //Creation Logic for Contact Point Phone
            if(con.Phone != null && (isInsert || recordCreationMap.get(con.IndividualId + 'ContactPointPhone'))) {
                ContactPointPhone cpe = new ContactPointPhone(
                    TelephoneNumber = con.Phone,
                    IsPrimary =  true,
                    ParentId = con.IndividualId,
                    ActiveFromDate = System.today(),
                    FormattedInternationalPhoneNumber = '+' + con.Phone
                );
                contactPointPhoneMap.put(con.IndividualId, cpe);
            }
            

            //Creation Logic for Contact Point Consent Phone
            //Creation Logic for Contact Point Consent License
            //Creation Logic for Contact Point Consent Privacy
        }

        if(!contactPoinEmailMap.isEmpty()) {
            insert contactPoinEmailMap.values();
        }
        if(!contactPointPhoneMap.isEmpty()) {
            insert contactPointPhoneMap.values();
        }

        Map<String, Id> brandMap = new Map<String, Id>();
        Map<String, Id> dataPurposeMap = new Map<String, Id>();
        Map<String, Id> engagementChannelMap = new Map<string, Id>();

        for(BusinessBrand brand : [SELECT Id, Name FROM BusinessBrand]) {
            brandMap.put(brand.Name, brand.Id);
        }
        for(DataUsePurpose purpose : [SELECT Id, Name FROM DataUsePurpose]) {
            dataPurposeMap.put(purpose.Name, purpose.Id);
        }
        for(EngagementChannelType type : [SELECT Id, Name FROM EngagementChannelType]) {
            engagementChannelMap.put(type.Name, type.Id);
        }

        for(Contact con : newContactsList) {
            if(con.BrandName__c != 'GainConnect' && Trigger.isExecuting) {
                continue;
            }
            //Creation Logic for Contact Point Consent Email
            ContactPointEmail cpe = contactPoinEmailMap.containsKey(con.IndividualId) ? contactPoinEmailMap.get(con.IndividualId)
                                        : individuals.containsKey(con.IndividualId) && 
                                            !individuals.get(con.IndividualId).ContactPointEmails.isEmpty()
                                        ? individuals.get(con.IndividualId).ContactPointEmails[0] :null;
            Boolean isEmailPointAvailable = cpe != null;
            if(isEmailPointAvailable && (isInsert || recordCreationMap.get(con.IndividualId + 'ContactPointEmailConsent'))) {
                consentsToInsert.add(createContactPointConsent(brandMap.get(con.BrandName__c), dataPurposeMap.get('Marketing'), 'Email', cpe.Id, !con.HasOptedOutOfEmail, con.Id, engagementChannelMap.get('Email')));
            }
            if(isEmailPointAvailable && (isInsert || recordCreationMap.get(con.IndividualId + 'License Agreement'))) {
                consentsToInsert.add(createContactPointConsent(brandMap.get(con.BrandName__c), dataPurposeMap.get('License Agreement'), 'Email', cpe.Id, con.LicenseAgreementConsent__c, con.Id, engagementChannelMap.get('General')));
            }
            if(isEmailPointAvailable && (isInsert || recordCreationMap.get(con.IndividualId + 'Privacy'))) {
                consentsToInsert.add(createContactPointConsent(brandMap.get(con.BrandName__c), dataPurposeMap.get('Privacy'), 'Email', cpe.Id, con.PrivacyConsent__c,  con.Id, engagementChannelMap.get('General')));
            }
            if(isEmailPointAvailable && con.MailingCountry == 'Thailand' && (isInsert || recordCreationMap.get(con.IndividualId + 'Education'))) {
                consentsToInsert.add(createContactPointConsent(brandMap.get(con.BrandName__c), dataPurposeMap.get('Education'), 'Email', cpe.Id, con.EducationConsent__c,  con.Id, engagementChannelMap.get('General')));
            }
            if(String.isNotBlank(con.Phone) && (isInsert || recordCreationMap.get(con.IndividualId + 'ContactPointPhoneConsent'))) {
                ContactPointPhone cpp = contactPointPhoneMap.containsKey(con.IndividualId) ? contactPointPhoneMap.get(con.IndividualId)
                : individuals.containsKey(con.IndividualId) && 
                    !individuals.get(con.IndividualId).ContactPointPhones.isEmpty()
                ? individuals.get(con.IndividualId).ContactPointPhones[0] :null;
                consentsToInsert.add(createContactPointConsent(brandMap.get(con.BrandName__c), dataPurposeMap.get('Marketing'), 'Phone', cpp.Id, !con.et4ae5__HasOptedOutOfMobile__c, con.Id, engagementChannelMap.get('Phone')));
            }
        }
        
        insert consentsToInsert;


    }
    public static ContactPointConsent createContactPointConsent(Id brandId, Id dataUsePurpose, 
        String type, Id cpId, Boolean isOptIn, Id conId, Id engagementChannelTypeId) {
        return new ContactPointConsent(
            BusinessBrandId = brandId,
            BusinessBrandName__c = 'GainConnect',//Populate it from the brand record
            CaptureContactPointType = type,
            CaptureSource  = 'Web',
            CaptureDate = System.today(),
            ContactPointId = cpId,
            DataUsePurposeId = dataUsePurpose,
            Name = 'Consent - ' + conId,
            PrivacyConsentStatus = isOptIn ? 'OptIn' : 'OptOut',
            Contact__c = conId,
            EffectiveFrom = isOptIn ?  DateTime.now() : null,
            EngagementChannelTypeId = engagementChannelTypeId
        );
    }

    public static void populateIndividual(List<Contact> newContacts) {
        List<Individual> individuals = new List<Individual>();
        List<Contact> contacts = new List<Contact>();

        for(Contact con : newContacts) {
            if(String.isBlank(con.IndividualId)) {
                Individual indiv = new Individual(FirstName = con.FirstName, LastName = con.LastName);
                individuals.add(indiv);
                contacts.add(con);
            }
            
        }
        if(!individuals.isEmpty()) {
            insert individuals;
            for(Integer i = 0; i < individuals.size(); i++) {
                contacts[i].IndividualId = individuals[i].Id;
            }
        }
    }

    public static Boolean getConsentRecord(Map<String, ContactPointConsent> typeToConsentMap, 
                String key, Boolean consentStatus, List<Sobject> recordstoUpdate) {
        if(!typeToConsentMap.containsKey(key)) {
            return true;
        }
        ContactPointConsent consent = typeToConsentMap.get(key);
        consent.PrivacyConsentStatus = consentStatus ? 'OptIn' : 'OptOut';
        //Update ActiveToDate to today if the consent is withdrawn
        //update ActiveToDate blank if the consent is given
        //update ActiveFromDate to current date if the consent is given
        consent.EffectiveTo = consentStatus ? null : DateTime.now();
        consent.EffectiveFrom = consentStatus ?  DateTime.now() : consent.EffectiveFrom;
        recordstoUpdate.add(consent);
        return false;
    }
     

    /**
     * This method checks if there are already Cases created for newly created Contacts with brands and if not
     * Cases are created and inserted ONLY for Gain Connect Brazil and RX South Africa (BR GainConnect and South Africa RX)
     * @param upsertedContacts list of newly created contacts
     */

     public static void createAndInsertCasesForBrands(List<Contact> upsertedContacts, Map<Id, Contact> oldContactMap) {
        //for email verification check
        List<String> verifiedContacts = new List<String>();
        List<Case> casesForInsert = new List<Case>();
        List<Contact> checkExisitngCaseForContacts = new List<Contact>();
        
        String userIDForCaseCreation = [SELECT Id__c FROM GainConnectIntegrationId__mdt LIMIT 1].Id__c;
		String triggerUserId = UserInfo.getUserId();
        Boolean checkUserProfile = userIDForCaseCreation.contains(triggerUserId);
        
        for(Contact con : upsertedContacts){
            if(con.IsEmailVerified__c && (oldContactMap == null || con.IsEmailVerified__c  != oldContactMap.get(con.Id).IsEmailVerified__c)){
                verifiedContacts.add(con.Id);
            }
        }
        if(!verifiedContacts.isEmpty()){
            checkExisitngCaseForContacts = [
				SELECT 
					Id, 
					AccountId, 
					FirstName, 
					LastName, 
					MailingCountry,
                    Latest_Brand_Name__c,
                    BrandName__c,
					(SELECT Id FROM Cases)
                FROM Contact
                WHERE Id IN: verifiedContacts
			];
        }
        
        if(!checkExisitngCaseForContacts.isEmpty()){
            Database.DMLOptions dmlOpts = getDmlOptionsForTriggeringCaseAssignmentRules();
            for(Contact con : checkExisitngCaseForContacts){
                if(con.cases.isEmpty()){
                    casesForInsert.add(createCase(con, dmlOpts, checkUserProfile));
                }
            }
            insert casesForInsert;
        } 
    }
    
    // checking existing contacts 
    public static void Contactvalidation(List<Contact> contacts){
        set<string> setrecEmails = new set<string>();
        set<string> setrecBrandNames = new set<string>();
        set<string> setrecmailings = new set<string>();
        for(contact con:contacts){
            setrecEmails.add(con.Email); 
            setrecBrandNames.add(con.BrandName__c); 
            setrecmailings.add(con.MailingCountry); 
        }

        Map<string,contact> contactuniqurekey = new map<string,contact>();
        List<contact> listContact = [SELECT id,Name,BrandName__c,Email,MailingCountry from contact where Email!=null and BrandName__c!=null and MailingCountry!=null and BrandName__c IN :setrecBrandNames AND Email IN : setrecEmails AND MailingCountry IN : setrecmailings];
        system.debug('====listContact======='+listContact.size());

        for(contact c:listContact){
            contactuniqurekey.put(c.BrandName__c+'_'+c.Email+'_'+c.MailingCountry,c);
        }
        system.debug('====contactuniqurekey======='+contactuniqurekey);   

        for(contact con:contacts){
            if(contactuniqurekey.containsKey(con.BrandName__c+'_'+con.Email+'_'+con.MailingCountry))  {
               con.addError('Contact Exist with same Email and Brand Name and Mailing country');  
            } 
           }
    }

    /*
       @Description: This method is called when a new contact is created without the accountid.
       @Returns: always returns null
    */
    public static void populateAccountOnContact(List<Contact> newContacts) {
        String externalAccountName = newContacts[0].ExternalAccountName__c;
        if (!String.isBlank(externalAccountName)) {
            List<Account> matchingAccounts = [SELECT Id FROM Account WHERE Name = :externalAccountName LIMIT 1];
             if (!matchingAccounts.isEmpty()) {
                newContacts[0].AccountId = matchingAccounts[0].Id;
            } else {
                Account newAccount = new Account(Name = externalAccountName);
                insert newAccount;
                newContacts[0].AccountId = newAccount.Id;
            }
        } else {
            List<Account> galdermaAccounts = [SELECT Id,Name FROM Account WHERE Name = 'Galderma' LIMIT 1];          
            if (galdermaAccounts.size() > 0 && galdermaAccounts[0].Name!='Galderma') {         
                newContacts[0].AccountId = galdermaAccounts[0].Id;
            }
        }
        
    }

    public static void checkIfContactHasFilledPhoneNumberWithConsent(List<Contact> upsertedContacts) {
        for (Contact upsertedContact : upsertedContacts) {
            if (upsertedContact.HasPhoneConsentRecord__c && (upsertedContact.Phone == '' || upsertedContact.Phone == null
            || String.isEmpty(upsertedContact.Phone))) {
                upsertedContact.addError('This contact has Phone Consent but no phone number filled, you should add the phone number.');
            
            }
        }
    }

    /**
   * This method creates DML options for firing Case assignment rules when a Case is created in Apex
   * @return Database.DMLoptions
   */
    static Database.DMLOptions getDmlOptionsForTriggeringCaseAssignmentRules() {
        AssignmentRule AR = [SELECT Id
               FROM AssignmentRule
               WHERE SobjectType = 'Case'
                 AND Active = true
               LIMIT 1];
        // Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.Id;
        dmlOpts.EmailHeader.triggerUserEmail = true;
        return dmlOpts;
    }

    /**
   * @param insertedContact Contact that was just created
   * @param dmlOpts DML options that trigger Case assignment
   *
   * @return created Case
   */
    public static Case createCase(Contact insertedContact, Database.DMLOptions dmlOpts, Boolean isIntegrationUser) {
        String hcpValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HCP Validation').getRecordTypeId();
        String Name = insertedContact.FirstName != null ? insertedContact.FirstName
                + ' ' + insertedContact.LastName : insertedContact.LastName; 
        Case caseToInsert = new Case(
                AccountId = insertedContact.AccountId, 
                ContactId = insertedContact.Id, 
                Origin = isIntegrationUser ?  'Web' : 'Gain Connect - User Registration', 
                Reason = isIntegrationUser ? 'User Verification' : '', 
                Subject = Name, 
                Description = isIntegrationUser ? 'User still to be verified' : Name + ' HCP Validation',
                Contact_Country__c = insertedContact.MailingCountry,
                RecordTypeId = hcpValidationRecordTypeId, 
                Tech_Brand_Name__c = String.isNotBlank(insertedContact.Latest_Brand_Name__c) ? insertedContact.Latest_Brand_Name__c : insertedContact.BrandName__c
            );
        // Setting the DMLOption on Case instance
        caseToInsert.setOptions(dmlOpts);
        return caseToInsert;
    }
    /**
   * @param insertedContact Contact that was just created from Flow
   *
   * @return created Case
   */
    /*@InvocableMethod(label='Create Case Record' description='to create the case related to the Contact')
    public static void createCaseFromFlow(List<Contact> insertedContact) {
        system.debug('insertedContact'+insertedContact);
        Database.DMLOptions dmlOpts = getDmlOptionsForTriggeringCaseAssignmentRules();
        String hcpValidationRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('HCP Validation').getRecordTypeId();
        List<Case> caseToBeInserted = new List<Case>();
        for(Contact newcase:insertedContact){
            Case caseToInsert = new Case(
            AccountId = newcase.AccountId, 
            ContactId = newcase.Id, 
            Description = 'User still to be verified',
            Origin = 'Gain Connect - User Registration', 
            Subject = newcase.FirstName != null ? newcase.FirstName
            + ' ' + newcase.LastName : newcase.LastName, 
            Contact_Country__c = newcase.MailingCountry,
            RecordTypeId = hcpValidationRecordTypeId, 
            Status = 'New'
        );
            caseToBeInserted.add(caseToInsert);
        }
        
        // Setting the DMLOption on Case instance
        for(Case newcase:caseToBeInserted){
            newcase.setOptions(dmlOpts);
        }
        System.debug('caseToBeInserted final'+caseToBeInserted);
        //return caseToInsert;
        insert caseToBeInserted;
    }*/

    /**
     * @param newList list of Contacts coming from API
     *  This method creates Tech_Brand_Name__c string and sets values for multiselect picklist Brand_Name__c when inserting Contacts
     *
     * @return list of inserted Contacts
     */
    public static List<Contact> createMultiPicklistWhenWhenInsert(List<Contact> newList) { // updateBrandMultiPicklistWhenUpdate
        List<Contact> contactListToUpdate = new List<Contact>();
        for (Contact triggeredContact : newList) {
            triggeredContact.Latest_Brand_Name__c = triggeredContact.BrandName__c;
            triggeredContact.Tech_Brand_Name__c = triggeredContact.BrandName__c;
            contactListToUpdate.add(triggeredContact);
        }
        return contactListToUpdate;
    }

    public static void setPhoneNumberInCorrectFormat(List<Contact> contactList, Map<Id, Contact> oldMap) {
        Map<String, String> countryCodesByCountry = new Map<String, String>();
        List<CountryCode__c> countryCodeList = [SELECT Name, Code__c FROM CountryCode__c];    
        for (CountryCode__c countryCode : countryCodeList) {
            countryCodesByCountry.put(countryCode.Name, countryCode.Code__c);
        }    
        
        for (Contact contactToInsert : contactList) {
            if (!String.isEmpty(contactToInsert.Phone) && (oldMap == null || (oldMap != null && oldMap.get(contactToInsert.Id).Phone != contactToInsert.Phone))) {     
                if (!String.isEmpty(contactToInsert.Phone.replaceAll('(?!^\\+)[^\\d]', ''))&& !String.isEmpty(contactToInsert.MailingCountry)) {
                    contactToInsert.Phone = countryCodesByCountry.get(contactToInsert.MailingCountry) != null ? countryCodesByCountry.get(contactToInsert.MailingCountry) + contactToInsert.Phone.replaceAll('(?!^\\+)[^\\d]', '') : contactToInsert.Phone.replaceAll('(?!^\\+)[^\\d]', '');
            }
            }
        }
    }

    public static void sAPCDCMakeCallout(List<Contact> contacts) {
        if (!System.isFuture() && !Test.isRunningTest()) {
            SAPCDCallout.makeCallout(contacts);
        }
    }

    //added for privacy consent status update
    public static Boolean isOptedOutOfEmail(Boolean newHasOptedOutOfEmailvalue, Boolean oldHasOptedOutOfEmailvalue) {
        return newHasOptedOutOfEmailvalue != oldHasOptedOutOfEmailvalue;
    }

    public static void processContactPointConsentRecord(List<Contact> newContacts, Map<Id, Contact> oldMap) {
        Map<Id, Contact> contactswithEmailhasoptoutValue = new Map<Id, Contact>();
        for(Contact eachContact: newContacts){
            if(eachContact.BrandName__c == 'GainConnect') {
                continue;
            }
            if (isOptedOutOfEmail(eachContact.HasOptedOutOfEmail, oldMap.get(eachContact.Id).HasOptedOutOfEmail)){
                contactswithEmailhasoptoutValue.put(eachContact.Id, eachContact);
            }                
        }
        if (!contactswithEmailhasoptoutValue.isEmpty()){
            processConsentBasedonEmailOptoutValue(contactswithEmailhasoptoutValue);
        }
    }

    public static void processConsentBasedonEmailOptoutValue(Map<Id, Contact> contactswithEmailhasoptoutValue){
        List<Id> brandIds = new List<Id>();
        Map<Id, BusinessBrand> brandMap = new Map<Id, BusinessBrand>();   
        
        List<ContactPointConsent> consents = [
            SELECT Id,PrivacyConsentStatus, EffectiveFrom, Contact__c, CaptureContactPointType, BusinessBrandId
            FROM ContactPointConsent 
            WHERE Contact__c IN: contactswithEmailhasoptoutValue.keySet()
            AND CaptureContactPointType = 'Email'
            ];
        
        for (ContactPointConsent consent:consents)
        {
            brandIds.add(consent.BusinessBrandId);
        }
        
        List<BusinessBrand> brands = [SELECT id, Name FROM BusinessBrand WHERE id IN: brandIds];
        
        for (BusinessBrand brand:brands)
        {
            brandMap.put(brand.id, brand);
        }
        
        updateConsents(consents, contactswithEmailhasoptoutValue, brandMap);
    }

    public static void updateConsents(List<ContactPointConsent> consents, Map<Id, Contact> contactswithEmailhasoptoutValue, Map<Id, BusinessBrand> brandMap){
        for (ContactPointConsent consent: consents){
            if (contactswithEmailhasoptoutValue.get(consent.Contact__c).BrandName__c == brandMap.get(consent.BusinessBrandId).Name)
            {
                consent.PrivacyConsentStatus = contactswithEmailhasoptoutValue.get(consent.Contact__c).HasOptedOutOfEmail == true?'OptOut':'OptIn';
                consent.EffectiveFrom = DateTime.now();
            }                        
        }
        if (consents.size() > 0){
            System.debug('===Consents-to-update==='+ consents);
            update consents;
        }
    }
    //added for Email Verification Key generation
    public static List<Contact> populateEmailVerificationKey(List<Contact> newList) { 
        return HCPUserRegistrationService.populateEmailVerificationKey(newList);
      }
    public static void doCommerceCloudCallOut(List<Contact> newContacts, Map<Id, Contact> oldConMap) {
            //contact Ids of fullyTrusted and isActive=true Contact
            List<String> ContactIdslist= new List<String>();
            string email;
            for(Contact cnt : newContacts){
                Contact oldCon = oldConMap.get(cnt.Id);
                email = oldCon.Email;
                system.debug(oldCon.PlatformStatus__c);
            if((cnt.Email != oldCon.Email || cnt.Pro_Segment__c != oldCon.Pro_Segment__c)){
                if(cnt.RegistrationConfirmed__c==true){
system.debug(cnt.id);
                ContactIdslist.add(cnt.id); 
                }

            }
            }
            if(!ContactIdslist.isEmpty()){
                CommerceCloudCallout.updateCustomerInCommerceCloud(ContactIdslist,email);
        } 
    }
    public static void syncUserData(Map<Id, Contact> newContactMap, Map<Id, Contact> oldContactMap) {
		Map<String, String> syncContactFields = new Map<String, String> {
			'FirstName' => 'FirstName',
			'LastName' => 'LastName',
			'Email' => 'Email',
			'Profession__c' => 'Profession__c',
			'HasOptedOutOfEmail' => 'HasEmailOptedOut__c',
			'MailingCountry' => 'Country',
			'PrivacyConsent__c' => 'PrivacyConsent__c',
			'NPIId__c' => 'MedicalId__c',
			'Phone' => 'Phone',
			'MailingStreet' => 'Street',
			'MailingPostalCode' => 'PostalCode',
			'MiddleName' => 'MiddleName',
			'Business_Entity_Name__c' => 'CompanyName',
			'Title' => 'Title',
			'MailingCity' => 'City',
            'CIAMID__c' => 'CIAMID__c',
            'LicenseAgreementConsent__c' => 'LicenseAgreementConsent__c',
            'EducationConsent__c' => 'EducationConsent__c'
		};
		Set<Id> changedContactIds = new Set<Id>();
		for(Contact con : newContactMap.values()) {
			if(con.BrandName__c != 'GainConnect') {
				continue;
			}
			for(String fieldName : syncContactFields.keySet()) {
				Contact oldCon = oldContactMap.get(con.Id);
				if(con.get(fieldName) != oldCon.get(fieldName)) {
					changedContactIds.add(con.Id);
					//break
				}
			}
		}
		if(!changedContactIds.isEmpty()) {
			List<User> users = [
				SELECT Id, ContactId FROM User WHERE ContactId IN : changedContactIds
			];
			for(User usr : users) {
				Contact newCon = newContactMap.get(usr.ContactId);
				Contact oldCon = oldContactMap.get(usr.ContactId);
				for(String fieldName : syncContactFields.keySet()) {
					if(newCon.get(fieldName) != oldCon.get(fieldName)) {
						String usrFldName = syncContactFields.get(fieldName);
						usr.put(usrFldName, newCon.get(fieldName));
					}
				}
			}
			update users;
		}
}
    
    //Handle Inflight Registered Contacts but Email not Verified   
    public static void hcpInflightRegContactsMigration(List<Contact> newContacts, Map<Id, Contact> oldConMap) {
        Database.DMLOptions dmlOptions= getDmlOptionsForTriggeringCaseAssignmentRules();
        Map<String, HCPUserMapping__mdt> userLocaleMap = new Map<String, HCPUserMapping__mdt>();
        Id profileId = null;
        List<Contact> updateContacts = new List<Contact>();
        List<Case> cases = new List<Case>();
        List<User> users = new List<User>();
        Set<Id> brazilContactIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        for(Contact con : newContacts){
            Contact oldCon = oldConMap != null ? oldConMap.get(con.Id) : null;
            Boolean isMarketActive = String.isNotBlank(con.MailingCountry) && System.Label.HCPActiveMarkets.contains(con.MailingCountry);
            Boolean isInflightReg = oldCon != null && con.isEmailVerified__c != oldCon.isEmailVerified__c 
                                        && con.isEmailVerified__c && con.BrandName__c =='GainConnect' 
                                        && con.TrustLevel__c == 'ProcessManually' && !con.IsTest__c
                                        && String.isNotBlank(con.CIAMID__C)
                                        && isMarketActive;
            Boolean isBrazilReg = oldCon == null 
                                    && System.Label.HCPExecuteDrupalReg == 'Yes'
                                    && con.MailingCountry == 'Brazil' 
                                    && con.BrandName__c =='GainConnect' 
                                    && con.TrustLevel__c == 'ProcessManually'
                                    && String.isBlank(con.CIAMID__c)
                                    && con.LeadSource == 'Drupal Registration';
            if(isInflightReg || isBrazilReg){
                contactIds.add(con.Id); 
            }
            if(isBrazilReg) {
                brazilContactIds.add(con.Id);
            }
        }

        if(!contactIds.isEmpty()) {
            updateContacts = [
                SELECT Id,FirstName,LastName,Email,Profession__c,
                    HasOptedOutOfEmail,CIAMId__c,
                    PrivacyConsent__c,NPIId__c,
                    MailingStreet,MiddleName,Business_Entity_Name__c,
                    Title,MailingCity,MailingPostalCode,EducationConsent__c,
                    EmailVerificationKey__c,isEmailVerified__c,
                    isVerificationEmailSent__c,account.Id,MailingCountry, 
                    Latest_Brand_Name__c , BrandName__c, UserSecretToken__c, Phone,
                    (SELECT Id from Users) 
                FROM Contact WHERE Id IN : contactIds
            ];
            //Locale Mapping Logic
            for(HCPUserMapping__mdt mdtRec : HCPUserMapping__mdt.getAll().values()) {
                userLocaleMap.put(mdtRec.Country__c, mdtRec);
            }
            Profile hcpProfile = [SELECT Id FROM Profile WHERE Name =: System.Label.HCPSiteProfileName];
            profileId = hcpProfile.Id;
            Map<Id, User> conToUserMap = new Map<Id, User>();
            Map<Id, Contact> idToConMap = new Map<Id, Contact>();
            List<Contact> clearContacts = new List<Contact>();
            for(Contact con : updateContacts) {
                if(con.Users.isEmpty()) {
                    HCPUserMapping__mdt localeInfo = userLocaleMap.get(con.MailingCountry);
                    HCPUserMigrationBatch obj = new HCPUserMigrationBatch();
                    User userRec = obj.getUserRecord(localeInfo, con, profileId);
                    idToConMap.put(con.Id,con);
                    if(brazilContactIds.contains(con.Id)) {
                        clearContacts.add(new Contact(Id = con.Id, UserSecretToken__c = ''));
                        userRec.MigratedFromCDC__c = false;
                       
                    }
                    userRec.IsActive = true;
                    conToUserMap.put(con.Id, userRec);
                    //users.add(obj.getUserRecord(localeInfo, con, profileId));
                    
                }
            }
            if(!conToUserMap.isEmpty()) {
                insert conToUserMap.values();
                for(Id conId : conToUserMap.keySet()) {
                    User userRec = conToUserMap.get(conId);
                    Contact conRec = idToConMap.get(conId);
                    if(brazilContactIds.contains(conId) && String.isNotBlank(conRec.UserSecretToken__c)) {
                        System.setPassword(userRec.Id, conRec.UserSecretToken__c);
                    }
                }
    
                if(!clearContacts.isEmpty()) {
                    TriggerSkipperUtility.markTriggerRun('Contact', 'After');
                    TriggerSkipperUtility.markTriggerRun('Contact', 'Before');
                    update clearContacts;
                    TriggerSkipperUtility.resetTriggerRun('Contact', 'After', true);
                    TriggerSkipperUtility.resetTriggerRun('Contact', 'Before', true);
                }
            }
        }
       
    }

}