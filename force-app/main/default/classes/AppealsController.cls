public class AppealsController {

    @AuraEnabled(cacheable=true)
    public static Integer getOpenAppeals() {
        Id currentUserId = UserInfo.getUserId();

        // Retrieve Accounts the current user owns
        List<Account> userAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

        if (userAccounts.isEmpty()) {
            return 0; // No related Account, return 0
        }

        // Retrieve related Cases (Claims) for the user's Account(s)
        List<Case> relatedCases = [SELECT Id FROM Case WHERE AccountId IN :userAccounts];

        if (relatedCases.isEmpty()) {
            return 0; // No related Cases, return 0
        }

        // Retrieve Open Appeals linked to the user's Cases (Claims)
        return [
            SELECT COUNT()
            FROM Appeal__c 
            WHERE Denied_Case__c IN :relatedCases 
            AND Status__c != 'Decision Made'
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Integer getClosedAppeals() {
        Id currentUserId = UserInfo.getUserId();

        // Retrieve Accounts the current user owns
        List<Account> userAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

        if (userAccounts.isEmpty()) {
            return 0; // No related Account, return 0
        }

        // Retrieve related Cases (Claims) for the user's Account(s)
        List<Case> relatedCases = [SELECT Id FROM Case WHERE AccountId IN :userAccounts];

        if (relatedCases.isEmpty()) {
            return 0; // No related Cases, return 0
        }

        // Retrieve Closed Appeals linked to the user's Cases (Claims)
        return [
            SELECT COUNT()
            FROM Appeal__c 
            WHERE Denied_Case__c IN :relatedCases 
            AND Status__c = 'Decision Made'
            WITH SECURITY_ENFORCED
        ];
    }
}