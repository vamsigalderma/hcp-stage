global  without sharing class HCPUserManagement implements Queueable{

	global List<Case> cases = new List<Case>();
	global HCPUserManagement(List<Case> cases) {
		this.cases = cases;
	}

	@InvocableMethod(label = 'Update HCP User Access')
	global static List<String> updateUserAccess(List<Case> cases) {
		System.enqueueJob(new HCPUserManagement(cases));
		return new List<String>();
	}

	public void execute(QueueableContext qc){
		try {
			
		//update users
		Map<Id, Case> conToCaseMap = new Map<Id, Case>();
		List<User> usersToUpdate = New List<User>();
		Map<String, String> userLocaleMap = new Map<String, String>();
       
		for(Case c : cases) {
			if(String.isNotBlank(c.ContactId)) {
				conToCaseMap.put(c.ContactId, c);
			}
		}
		
		for(HCPUserMapping__mdt mdtRec : HCPUserMapping__mdt.getAll().values()) {
			//userLocaleMap.put(mdtRec.Permission_Set_Name__c, mdtRec.Country__c);
			userLocaleMap.put(mdtRec.Country__c, mdtRec.Permission_Set_Name__c);
		}

		List<PermissionSet> permissionSets = [SELECT Id, Name FROM PermissionSet WHERE Name IN :userLocaleMap.values()];
		Map<String, Id> countryToPsMap = new Map<String, Id>();
		List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();
		Map<String, Id> psMap = new Map<String, Id>();
		for(PermissionSet ps : permissionSets) {
			psMap.put(ps.Name, ps.Id);
			// if(userLocaleMap.containsKey(ps.Name)) {
			// 	countryToPsMap.put(userLocaleMap.get(ps.Name), ps.Id);
			// }
			
		}

		for(String countryName : userLocaleMap.keySet()) {
			String psName = userLocaleMap.get(countryName);
			if(psMap.containsKey(psName)) {
				countryToPsMap.put(countryName, psMap.get(psName));
			}

		}
        System.debug('conToCaseMap---'+conToCaseMap.keySet());
		for(User usr : [SELECT Id, IsActive, ContactId, Contact.MailingCountry, Contact.BrandName__c 
						FROM User 
						WHERE ContactId IN :conToCaseMap.keySet()]) {
            System.debug('usr---'+usr);             
			//check if we need to update the user record.
			Boolean IsValidCase = conToCaseMap.get(usr.ContactId).Status == 'Closed - verified';
			if(usr.IsActive != IsValidCase) {
				usr.IsActive = IsValidCase;
				usersToUpdate.add(usr);
			}
			//Map the PSA records
			if(IsValidCase && countryToPsMap.containsKey(usr.Contact.MailingCountry)) {
				assignments.add(new PermissionSetAssignment(
					AssigneeId = usr.Id, 
					PermissionSetId = countryToPsMap.get(usr.Contact.MailingCountry)
					)
				);
			}
		}
		if(!usersToUpdate.isEmpty()) {
			update usersToUpdate;
		}
		//add Permission Sets if required
        if(!assignments.isEmpty()) {
			insert assignments;
		}
    }
catch(Exception e) {
			//Send Email to the Admin
			//Send an email to developer or batch creator
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] { System.Label.HCPAdminEmail };
			message.subject = 'Error : Activating the user';
			String errorMessage = 'Contact Id: ' + cases[0].Id;
			message.plainTextBody = errorMessage + '\nError Message: ' + e.getMessage();
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> { message };
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
		}
		
	}
	@AuraEnabled(cacheable = false)
	public static Boolean checkUser(String emailAddress) {
		List<User> users = [
			SELECT 
			Id, 
			(SELECT Id FROM PermissionSetAssignments WHERE PermissionSet.Name LIKE '%Access') 
			FROM User 
			WHERE UserName =: emailAddress 
				AND IsActive = TRUE
				AND ContactId != NULL
			ORDER BY CreatedDate DESC LIMIT 1
		];

		return !users.isEmpty() && !users[0].PermissionSetAssignments.isEmpty();
	}

	@AuraEnabled(cacheable = false)
	public static Boolean resetGcUserPassword(String emailAddress) {
		return Site.forgotPassword(emailAddress);
	}

	@AuraEnabled(cacheable = false)
	public static Boolean updateUserRecord(){
		
		try {
			User currentUser = [SELECT Id, IsPasswordChanged__c FROM User WHERE Id =: UserInfo.getUserId()];
			if(!currentUser.IsPasswordChanged__c) {
				update new User(Id = currentUser.Id, IsPasswordChanged__c = true);
				return true;
			}
		}
		catch (Exception e) {
			
		}
		return true;
	}
	@AuraEnabled(cacheable = false)
	public static String getLoginUrl(){
		String loginLink = 'https://gainconnect.com';
		try {
			User currentUser = [SELECT Id, IsPasswordChanged__c, Contact.MailingCountry FROM User WHERE Id =: UserInfo.getUserId()];
			if(!currentUser.IsPasswordChanged__c || Test.isRunningTest()) {
				update new User(Id = currentUser.Id, IsPasswordChanged__c = true);


			}
			List<HCPUserMapping__mdt> userMapping = [SELECT Id, LoginUrl__c FROM HCPUserMapping__mdt WHERE Country__c =: currentUser.Contact.MailingCountry];
			if(!userMapping.isEmpty()) {
				loginLink = userMapping[0].LoginUrl__c;
			}


		}
		catch (Exception e) {
			
		}
		return loginLink;
	}

}