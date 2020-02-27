public with sharing class Auth0Controller {
    @AuraEnabled
    public static void updatePassword(String password) {
        try {
            User currentUser = [SELECT Id, Contact.Auth0_User_Id__c FROM User WHERE Id = :UserInfo.getUserId()];
            updatePassword(currentUser.Contact.Auth0_User_Id__c, password);
        } catch (GenericException e) {
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            throw new AuraHandledException('Failed to update the password');
        }
    }

    public static void updatePassword(String userId, String password) {
        Auth0Manager authManager = new Auth0Manager();
        authManager.updateUser(userId, new Map<String, Object>{'password' => password});
    }

    @AuraEnabled
    public static string confirmPasswordReset(Id contactId){
        Contact contact = [SELECT Id, Email  
            FROM Contact WHERE Id = :contactId LIMIT 1];
        Auth0Manager authManager = new Auth0Manager();
        return authManager.passwordChange(contact.email);
    }
}