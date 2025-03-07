public class ClaimsController {
    
    @AuraEnabled(cacheable=true)
    public static Integer getOpenClaims() {
        Id currentUserId = UserInfo.getUserId();

        // Retrieve the Accounts the current user owns or has access to
        List<Account> userAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

        if (userAccounts.isEmpty()) {
            return 0; // No related Account, return 0
        }

        // Retrieve Open Cases (Claims) associated with the user's Account(s)
        return [
            SELECT COUNT()
            FROM Case 
            WHERE AccountId IN :userAccounts 
            AND Status NOT IN ('Closed', 'Decision Made')
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Integer getClosedClaims() {
        Id currentUserId = UserInfo.getUserId();

        // Retrieve the Accounts the current user owns or has access to
        List<Account> userAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

        if (userAccounts.isEmpty()) {
            return 0; // No related Account, return 0
        }

        // Retrieve Closed Cases (Claims) associated with the user's Account(s)
        return [
            SELECT COUNT()
            FROM Case 
            WHERE AccountId IN :userAccounts 
            AND Status IN ('Closed', 'Decision Made')
            WITH SECURITY_ENFORCED
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getClaimStatusCounts() {
        Id currentUserId = UserInfo.getUserId();

        // Retrieve the Accounts the current user owns or has access to
        List<Account> userAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

        if (userAccounts.isEmpty()) {
            return new Map<String, Integer>(); // No related Account, return empty map
        }

        Map<String, Integer> statusCounts = new Map<String, Integer>{
            'Received' => 0,
            'Under Review' => 0,
            'Evidence Gathering' => 0,
            'Decision Pending' => 0,
            'Decision Made' => 0,
            'Closed' => 0
        };

        // Aggregate Case (Claim) counts by status for the user's Accounts
        List<AggregateResult> results = [
            SELECT Status, COUNT(Id) totalcount
            FROM Case
            WHERE AccountId IN :userAccounts
            AND Status IN ('Received', 'Under Review', 'Evidence Gathering', 'Decision Pending', 'Decision Made', 'Closed')
            GROUP BY Status
        ];

        for (AggregateResult result : results) {
            String status = String.valueOf(result.get('Status')); // Get Status field
            Integer count = Integer.valueOf(result.get('totalcount')); 
            
            if (statusCounts.containsKey(status)) {
                statusCounts.put(status, count);
            }
        }

        return statusCounts;
    }
}