/*******************************************************************************************
* @Name         ContactTriggerHandler
* @Author       Merkele
* @Description  This is the trigger handler for Contact records.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          	Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Merkele       		08/11/2023         Initial Creation
*  2.0             Vamsi Krishna		08/11/2023         Added trigger framework logic. and moved all the code from trigger handler to service class

*******************************************************************************************/
public class ContactTriggerHandler extends TriggerHandler {

  public override void beforeInsert() {
	if (TriggerSkipperUtility.isAllowedToRun('Contact', 'Before')) {
		TriggerSkipperUtility.markTriggerRun('Contact', 'Before');
		ContactService.checkIfContactHasFilledPhoneNumberWithConsent((List<Contact>) Trigger.new);
		//Skip duplicate rule check if the contact is created through the webservice
		if(!ContactService.SKIP_DUPLICATE_RULE) {
			ContactService.Contactvalidation((List<Contact>) Trigger.new);
		}
	  	ContactService.populateAccountOnContact((List<Contact>) Trigger.new);
		ContactService.contactandAccountcreationandupdate(trigger.new); 
		ContactService.populateIndividual((List<Contact>) Trigger.new);
	}
  }

  public override void afterInsert() {
	if (TriggerSkipperUtility.isAllowedToRun('Contact', 'After')) {
		TriggerSkipperUtility.markTriggerRun('Contact', 'After');
		//String userIDForCaseCreation = [SELECT Id__c FROM GainConnectIntegrationId__mdt LIMIT 1].Id__c;
		//String triggerUserId = UserInfo.getUserId();
		//if (userIDForCaseCreation.contains(triggerUserId)) {
		//	ContactService.createAndInsertCasesForBrands((List<Contact>) Trigger.new);
		//}
		ContactService.createOrUpdateConsents((List<Contact>) Trigger.new, null);

	}
  }
  
  public override void beforeUpdate() {
	if (TriggerSkipperUtility.isAllowedToRun('Contact', 'Before')) {
		TriggerSkipperUtility.markTriggerRun('Contact', 'Before');
		ContactService.checkIfContactHasFilledPhoneNumberWithConsent((List<Contact>) Trigger.new);
		ContactService.populateIndividual((List<Contact>) Trigger.new);
		ContactService.populateAccountOnContact((List<Contact>) Trigger.new);
		ContactService.contactandAccountcreationandupdate(trigger.new); 
	}
  }
  
	public override void afterUpdate() {
		if (TriggerSkipperUtility.isAllowedToRun('Contact', 'After')) {
			TriggerSkipperUtility.markTriggerRun('Contact', 'After');
			String userIDForCaseCreation = [SELECT Id__c FROM GainConnectIntegrationId__mdt LIMIT 1].Id__c;
			String triggerUserId = UserInfo.getUserId();
			if (userIDForCaseCreation.contains(triggerUserId)) {
				Boolean createCase = false;
				for(Contact con : (List<Contact>) Trigger.new) {
					createCase = con.IsEmailVerified__c != ((Map<Id, Contact>)Trigger.oldMap).get(con.Id).IsEmailVerified__c && con.IsEmailVerified__c;
					break;
				}
				if(createCase) {
					ContactService.createAndInsertCasesForBrands((List<Contact>) Trigger.new);
				}
				
			}
			ContactService.processContactPointConsentRecord((List<Contact>) Trigger.new, (Map<Id, Contact>)Trigger.oldMap);
			ContactService.createOrUpdateConsents((List<Contact>) Trigger.new, (Map<Id, Contact>)Trigger.oldMap);
			ContactService.doCommerceCloudCallOut((List<Contact>) Trigger.new, (Map<Id, Contact>)Trigger.oldMap);

		}
	}
}