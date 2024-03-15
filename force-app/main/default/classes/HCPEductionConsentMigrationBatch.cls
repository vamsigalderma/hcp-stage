public with sharing class HCPEductionConsentMigrationBatch implements Database.Batchable<SObject>, Database.Stateful{

	public Id engagementChannelId;
	public Id dataUserPurposeId;
	public Id brandId;

	public HCPEductionConsentMigrationBatch() {
		//Throw error if data use purpose id , brand id and egagement channel ids are not available
		//Throw error if SkipTriggerFlows Permission is not enabled
	}
	

	
	public Database.QueryLocator start(Database.BatchableContext bc) {
		engagementChannelId = [SELECT Id FROM EngagementChannelType WHERE Name = 'General' LIMIT 1].Id;
		dataUserPurposeId = [SELECT Id FROM DataUsePurpose WHERE Name = 'Education' LIMIT 1].Id;
		brandId = [SELECT Id FROM BusinessBrand WHERE Name = 'GainConnect' LIMIT 1].Id;
		if(!FeatureManagement.checkPermission('Skip_Triggers_Flows') && !Test.isRunningTest()) {
			throw new CDCConsentDataUpdateBatch.CDCBatchException('User doesnt have the Skip_Triggers_Flows Permission Set. Please assign Skip_Triggerd_Flows PS to run this batch');
		}
		if(String.isBlank(engagementChannelId) || String.isBlank(dataUserPurposeId) || String.isBlank(brandId)) {
			throw new CDCConsentDataUpdateBatch.CDCBatchException('Brand or Data Use Purpose or ngagement Channel Type record is missing');
		}

		String innerQuery = '(SELECT Id, DataUsePurposeId, DataUsePurpose.Name, PrivacyConsentStatus, ContactPointId, CaptureContactPointType,EffectiveFrom,EffectiveTo,CaptureDate FROM Contact_Point_Consents__r WHERE DataUsePurpose.Name IN (\'Marketing\',\'Education\')) ';
		return Database.getQueryLocator('SELECT Id, Name, HasOptedOutOfEmail, et4ae5__HasOptedOutOfMobile__c, ' + innerQuery + ' FROM Contact WHERE MailingCountry = \'Thailand\' AND BrandName__c INCLUDES (\'GainConnect\')');
	}
	public void execute(Database.BatchableContext bc, List<Contact> contacts) {
		//Sync contact education consent with user education consent field
		//Skip the triggers
		List<ContactPointConsent> consentsToUpsert = new List<ContactPointConsent>();
		List<Contact> contactsToUpdate = new List<Contact>();
		for(Contact con : contacts) {
			
			con.HasOptedOutOfEmail = false;
			con.et4ae5__HasOptedOutOfMobile__c = false;
			Boolean IsEduConsentAvailable = false;
			Id contactPointId;
			DateTime effectiveFrom = null;
			DateTime effectiveTo = null;
			DateTime captureDate = null;
			for(ContactPointConsent consentRec : con.Contact_Point_Consents__r) {
				//Check if it is marketing
				if(consentRec.DataUsePurpose.Name == 'Marketing') {
					consentRec.PrivacyConsentStatus = 'NotSeen';
					if(consentRec.CaptureContactPointType == 'Email') {
						contactPointId = consentRec.ContactPointId;
						effectiveFrom = consentRec.EffectiveFrom;
						effectiveTo = consentRec.EffectiveTo;
						captureDate = consentRec.CaptureDate;
					}
					consentsToUpsert.add(consentRec);
				}
				//Check if it education
				else if(consentRec.DataUsePurpose.Name == 'Education') {
					IsEduConsentAvailable = true;
					//consentRec.PrivacyConsentStatus = con.EducationConsent__c ? 'Optin' : 'OptOut';
				}
				

			}
			if(!IsEduConsentAvailable && contactPointId != NULL) {
				//Copy the marketing consent to education consent
				con.EducationConsent__c = !con.HasOptedOutOfEmail;
				ContactPointConsent eduConsent = ContactService.createContactPointConsent(brandId, dataUserPurposeId, 'Email', contactPointId, con.EducationConsent__c, con.Id, engagementChannelId);
				eduConsent.EffectiveFrom = effectiveFrom;
				eduConsent.EffectiveTo = effectiveTo;
				eduConsent.CaptureDate = captureDate;
				consentsToUpsert.Add(eduConsent);
				contactsToUpdate.add(con);
			}
			

		}
		if(!contactsToUpdate.isEmpty()) {
			Database.update(contacts, false);
		}
		if(!consentsToUpsert.isEmpty()) {
			Database.upsert(consentsToUpsert, false);
		}
		
		
	}

	public void finish(Database.BatchableContext countryCodesByCountry) {
		/**
		 Database.executeBatch(new HCPEductionConsentMigrationBatch(), 1);
		 */
	}
}