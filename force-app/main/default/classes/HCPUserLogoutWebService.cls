/*****************************************************************
Name: HCPUserLogoutWebService
============================================================
Purpose: This API is consumed by Drupal System to logout the user from salesforce sso once the user clicks logout in Drupal.
User Story:
============================================================
History
-------
VERSION AUTHOR  DATE    DETAIL  Description
1.0 Vamsi Krishna   Jan 23, 2024  Created
*****************************************************************/
@RestResource(urlMapping = '/GainConnect/UserLogout')
global without sharing class HCPUserLogoutWebService {
    
    @HttpPost
    global static void doLogout() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        RestRequest request = RestContext.request;
        try {
            
            
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
            String userEmail = String.valueOf(requestBody.get('email'));
            String errorMessage = '';
            List<AuthSession> austhSessions = [
                SELECT
                    Id
                FROM AuthSession
                WHERE Users.Email =: userEmail AND Users.ContactId != NULL
            ];
            if(!austhSessions.isEmpty()) {
                delete austhSessions;
            }
            response.StatusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {'Success' => true, 'errorMessage' => ''}));

        }
        catch(Exception ex) {
            response.StatusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {'Success' => false, 'errorMessage' => ex.getMessage()}));
            insert new Tech_Log__c(Name = 'HCPUserLogoutWebService', Is_Error__c = true, Message__c = (ex.getMessage()).left(255), Request__c = request.requestBody.toString());
        }
        
    }
}