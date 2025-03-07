public class ClaimsAndAppealsController {

    @AuraEnabled(cacheable=true)
public static List<Map<String, String>> getClaimsAndAppealsOverview() {
    List<Map<String, String>> claimsAndAppeals = new List<Map<String, String>>();

    Id currentUserId = UserInfo.getUserId();

    // Retrieve the Account where the logged-in user is the owner
    List<Account> ownedAccounts = [SELECT Id FROM Account WHERE OwnerId = :currentUserId];

    if (ownedAccounts.isEmpty()) {
        return claimsAndAppeals; // No owned Account, return empty list
    }

    // Collect the Account Ids of the owned accounts
    List<Id> ownedAccountIds = new List<Id>();
    for (Account acc : ownedAccounts) {
        ownedAccountIds.add(acc.Id);
    }

    // Query for Claims (filter by owned AccountId)
    List<Case> claims = [SELECT Id, CaseNumber, Status, AccountId 
                         FROM Case 
                         WHERE Status != 'Closed' 
                         AND Status != 'Decision Made' 
                         AND AccountId IN :ownedAccountIds 
                         ORDER BY CreatedDate DESC 
                         LIMIT 5];
    
    for (Case claim : claims) {
        Map<String, String> claimData = new Map<String, String>();
        claimData.put('type', 'Claim');
        claimData.put('name', claim.CaseNumber);
        claimData.put('status', claim.Status);
        claimData.put('url', 'Claims_Data_Page__c');  // Link to the Claim detail page
        claimsAndAppeals.add(claimData);
    }

    // Query for Appeals (filter by owned AccountId)
    List<Appeal__c> appeals = [SELECT Id, Name, Status__c, Veteran_Name__c 
                               FROM Appeal__c 
                               WHERE Status__c != 'Decision Made' 
                               AND Veteran_Name__c IN :ownedAccountIds 
                               ORDER BY Date_Created__c DESC 
                               LIMIT 5];
    
    for (Appeal__c appeal : appeals) {
        Map<String, String> appealData = new Map<String, String>();
        appealData.put('type', 'Appeal');
        appealData.put('name', appeal.Name);
        appealData.put('status', appeal.Status__c);
        appealData.put('url', 'Claims_Data_Page__c');  
        claimsAndAppeals.add(appealData);
    }

    return claimsAndAppeals;
}



    // These methods are for Claims Data Page

    //Get current user Related_Veteran_Id__c
    @AuraEnabled(cacheable=true)
    public static Id getLoggedInVeteranAccountId(){
        User currentUser = [
            SELECT Related_Veteran_Id__c
             FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        return currentUser.Related_Veteran_Id__c;
    }


    // Will set this to a specific Veteran for testing purposes
    // Status != 'Decision Made' AND Status != 'Closed' AND 
    @AuraEnabled(cacheable=true)
    public static List<Case> getVeteranClaims(){

        Id veteranAccountId = getLoggedInVeteranAccountId();

        //AccountId = '0014U00003WsT4XQAV'
        return [
            SELECT Id, CaseNumber, Status, Claim_Type__c
            FROM Case
            WHERE AccountId = :veteranAccountId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Case getClaimDetails(Id claimId){
        if(String.isEmpty(claimId)){
            return null;
        }

        return [SELECT Id, CaseNumber, Status, Claim_Type__c, Final_Decision__c,
                    CreatedDate, ClosedDate, Subject, Description
            FROM Case
            WHERE Id = :claimId
            LIMIT 1];

    }

    //'0014U00003WsT4XQAV'
    // Status__c != 'Decision Made' AND Status__c != 'Closed'  AND
    
    @AuraEnabled(cacheable=true)
    public static List<Appeal__c> getVeteranAppeals(){

        Id veteranAccountId = getLoggedInVeteranAccountId();

        return [
            SELECT Id, Name, Appeal_Type__c, Status__c
            FROM Appeal__c
            WHERE  Denied_Case__r.AccountId = :veteranAccountId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Appeal__c getAppealDetails(Id appealId){
        if(String.isEmpty(appealId)){
            return null;
        }

        return [SELECT Id, Name, Status__c, Appeal_Type__c, Date_Closed__c, Date_Created__c,
                        Final_Decision__c, Reason_for_Appeal__c, Denied_Case__c
            FROM Appeal__c
            WHERE Id = :appealId
            LIMIT 1];

    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFiles(Id recordId){
        List<Map<String, String>> fileList = new List<Map<String, String>>();

        // Get the ContentDocumentIds linked to the Claim record
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
        ];

        // Extract only ContentDocumentIds
        List<Id> contantDocIds = new List<Id>();
        for( ContentDocumentLink link : links){
            contantDocIds.add(link.ContentDocumentId);
        }

        // Query ContantDocument using extracted IDs
        if(!contantDocIds.isEmpty()){
            List<ContentDocument> documents = [
                SELECT Id, Title, FileType
                FROM ContentDocument
                WHERE Id IN :contantDocIds
            ];

            // Create list of maps of contentDocument data properties
            for(ContentDocument doc : documents){
                Map<String, String> fileData = new Map<String, String>();

                fileData.put('Id', doc.Id);
                fileData.put('title', doc.Title);
                fileData.put('fileType', doc.FileType);
                fileData.put('downloadUrl', '/sfc/servlet.shepherd/document/download/' + doc.Id);
                fileList.add(fileData);
            }
        

        }
        return fileList;
    }


    //BACKUP CODEEEEEE HERE
     // These methods are for Claims Data Page
    // Will set this to a specific Veteran for testing purposes
    // @AuraEnabled(cacheable=true)
    // public static List<Case> getVeteranClaims(){
    //     return [
    //         SELECT Id, CaseNumber, Status, Claim_Type__c
    //         FROM Case
    //         WHERE Status != 'Decision Made' AND Status != 'Closed' AND AccountId = '0014U00003WsT4XQAV'
    //         ORDER BY CreatedDate DESC
    //     ];
    // }

    // @AuraEnabled(cacheable=true)
    // public static Case getClaimDetails(Id claimId){
    //     if(String.isEmpty(claimId)){
    //         return null;
    //     }

    //     return [SELECT Id, CaseNumber, Status, Claim_Type__c, Final_Decision__c,
    //                 CreatedDate, ClosedDate, Subject, Description
    //         FROM Case
    //         WHERE Id = :claimId
    //         LIMIT 1];

    // }

    // @AuraEnabled(cacheable=true)
    // public static List<Appeal__c> getVeteranAppeals(){
    //     return [
    //         SELECT Id, Name, Appeal_Type__c, Status__c
    //         FROM Appeal__c
    //         WHERE Status__c != 'Decision Made' AND Status__c != 'Closed' 
    //                 AND Denied_Case__r.AccountId = '0014U00003WsT4XQAV'
    //         ORDER BY CreatedDate DESC
    //     ];
    // }

    // @AuraEnabled(cacheable=true)
    // public static Appeal__c getAppealDetails(Id appealId){
    //     if(String.isEmpty(appealId)){
    //         return null;
    //     }

    //     return [SELECT Id, Name, Status__c, Appeal_Type__c, Date_Closed__c, Date_Created__c,
    //                     Final_Decision__c, Reason_for_Appeal__c, Denied_Case__c
    //         FROM Appeal__c
    //         WHERE Id = :appealId
    //         LIMIT 1];

    // }


    // @AuraEnabled(cacheable=true)
    // public static List<Map<String, String>> getFiles(Id recordId){
    //     List<Map<String, String>> fileList = new List<Map<String, String>>();

    //     // Get the ContentDocumentIds linked to the Claim record
    //     List<ContentDocumentLink> links = [
    //         SELECT ContentDocumentId
    //         FROM ContentDocumentLink
    //         WHERE LinkedEntityId = :recordId
    //     ];

    //     // Extract only ContentDocumentIds
    //     List<Id> contantDocIds = new List<Id>();
    //     for( ContentDocumentLink link : links){
    //         contantDocIds.add(link.ContentDocumentId);
    //     }

    //     // Query ContantDocument using extracted IDs
    //     if(!contantDocIds.isEmpty()){
    //         List<ContentDocument> documents = [
    //             SELECT Id, Title, FileType
    //             FROM ContentDocument
    //             WHERE Id IN :contantDocIds
    //         ];

    //         // Create list of maps of contentDocument data properties
    //         for(ContentDocument doc : documents){
    //             Map<String, String> fileData = new Map<String, String>();

    //             fileData.put('Id', doc.Id);
    //             fileData.put('title', doc.Title);
    //             fileData.put('fileType', doc.FileType);
    //             fileData.put('downloadUrl', '/sfc/servlet.shepherd/document/download/' + doc.Id);
    //             fileList.add(fileData);
    //         }
        

    //     }
    //     return fileList;
    // }





}