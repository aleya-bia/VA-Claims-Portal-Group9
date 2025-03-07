public class AccountOwnerUpdater {
    
    @future
    public static void updateAccountOwner(String userId, String accountId) {
        try {
            // Retrieve the Account and update the OwnerId
            Account acc = [SELECT Id, OwnerId FROM Account WHERE Id = :accountId LIMIT 1];
            acc.OwnerId = userId;
            update acc;
        } catch (Exception e) {
            System.debug('Error updating account owner: ' + e.getMessage());
        }
    }
}