public with sharing class ClaimsSubmissionInputFieldsController {

    @AuraEnabled
    public static Case createClaim(List<String> relData){
        try {
                String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
                Account userAccount = [SELECT Id, Name FROM Account WHERE (Name = :userName) LIMIT 1];

                Case claim = new Case(
                    AccountId = userAccount.Id,
                    RecordTypeId = '0124U000000F7S5QAK', //hardcoded, sadly. Attempting to query for it failed.
                    Claim_Type__c = relData.get(0),
                    Subject = relData.get(1),
                    Description = relData.get(2) + relData.get(3) + ' ' + relData.get(4) + ' ' + relData.get(5) + ' ' + relData.get(6) + relData.get(7) + ' ' + relData.get(8) + relData.get(9)
                );
                insert claim;
                return claim;
            } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void associateFilesWithClaimApex(List<ContentDocumentLink> contentDocumentLinks) {
        try {
            System.debug(contentDocumentLinks.get(0));
            insert contentDocumentLinks;
        } catch (Exception e) {
            System.debug(contentDocumentLinks.get(0));
            throw new AuraHandledException('Error associating files: ' + e.getMessage());
        }
    }
}