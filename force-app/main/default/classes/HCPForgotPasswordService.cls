@RestResource(urlMapping='/GainConnect/ResetPassword')
global without sharing class HCPForgotPasswordService {
    @httpPost
    global static void resetPassword() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        RestRequest request = RestContext.request;
        try {
            
            Map<String, Object> requestBody = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
            String userEmail = String.valueOf(requestBody.get('email'));
            String errorMessage= '';
            if(String.isNotBlank(userEmail)) {
                List<User> users = [
                    SELECT 
                        Id,
                        (
                            SELECT Id FROM PermissionSetAssignments
                            WHERE PermissionSet.Name LIKE '%_Access'
                        )
                    FROM User 
                    WHERE Email =: userEmail
                        AND ContactId != NULL
                        AND IsActive = TRUE
                    LIMIT 1
                ];
                if(users.isEmpty()) {
                    throw new CalloutException('User doesn\'t exist with this email address');
                }
                if(users[0].PermissionSetAssignments.isEmpty()) {
                    throw new CalloutException('User doesn\'t have access to any site.');
                }
                //Sends the reset passwiord email to the customer. User wont be able to login with the current password.
                System.resetPassword(users[0].Id, true);
                response.StatusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {'Success' => true, 'errorMessage' => ''}));
            }
            else {
                throw new CalloutException('Email address is empty');
            }
        }
        catch(Exception e){
            response.StatusCode = 500;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {'Success' => false, 'errorMessage' => e.getMessage()}));
            insert new Tech_Log__c(Name = 'HCPForgotPasswordService', Is_Error__c = true, Message__c = (e.getMessage()).left(255), Request__c = request.requestBody.toString());
        }
        
    }
}