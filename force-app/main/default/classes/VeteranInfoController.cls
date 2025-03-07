public with sharing class VeteranInfoController {
    public Account veteran {get; set; }
    public Account newAccount {get; set; }
    public List<Case>       Claims {get; set; }
    public List<Appeal__c>  Appeals {get; set; }

    public List<Case>       paginatedClaims {get; set; }
    public List<Appeal__c>  paginatedAppeals {get; set; }

    public Integer pageSize {get; set; }

    public Integer totalClaims {get; set; }
    public Integer currentClaimsPage {get; set; }

    public Integer totalAppeals {get; set; }
    public Integer currentAppealsPage {get; set; }

    public VeteranInfoController(ApexPages.StandardController stdController) {
        //this.veteran = (Account)stdController.getRecord();

        // Get the curernt user's information
        User currentUser = [
            SELECT Related_Veteran_Id__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        veteran = [
            SELECT Id, Name, Phone, Email__c, BillingStreet, BillingCity, BillingState, 
            Service_Start_Date__c, BillingPostalCode, BillingCountry, Military_Branch__c, 
            Service_End_Date__c, Discharge_Status__c, Disability_Percentage__c, 
            Social_Security_Number__c
                        FROM Account WHERE Id = :currentUser.Related_Veteran_Id__c LIMIT 1];


        // Set default page size and number of records to show
        pageSize = 5;
        currentClaimsPage   = 1;
        currentAppealsPage  = 1;

        
        Claims = [
            SELECT  CaseNumber, Status, CreatedDate, Claim_Type__c, Final_Decision__c,
                    ClosedDate, Subject, Description
            FROM Case
            WHERE AccountId = :veteran.Id AND Status NOT IN ('Closed', 'Decision Made')
            ORDER BY CreatedDate DESC
        ];

        Appeals = [
            SELECT  Name, Appeal_Type__c, Date_Closed__c, CreatedDate, Denied_Case__c, 
                    Final_Decision__c, Reason_for_Appeal__c, Status__c
            FROM Appeal__c
            WHERE Denied_Case__r.AccountId = :veteran.Id AND Status__c NOT IN ('Closed', 'Decision Made')
            ORDER BY CreatedDate DESC
        ];

        // Count the total record for Claims and Appeals 
        totalClaims = Claims.size();
        totalAppeals = Appeals.size();

        updatePaginatedClaims();
        updatePaginatedAppeals();

    }

    // Fetch Claims for the Current Page
    public void updatePaginatedClaims() {
        paginatedClaims = [SELECT   CaseNumber, Status, CreatedDate, Claim_Type__c, Final_Decision__c,
                                    ClosedDate, Subject, Description
                           FROM Case 
                           WHERE AccountId = :veteran.Id  AND Status NOT IN ('Closed', 'Decision Made')
                           ORDER BY CreatedDate DESC
                           LIMIT :pageSize OFFSET :((currentClaimsPage - 1) * pageSize)];
    }

    // Fetch Appeals for the Current page
    public void updatePaginatedAppeals() {
        paginatedAppeals = [SELECT  Name, Appeal_Type__c, Date_Closed__c, CreatedDate, Denied_Case__c, 
                                    Final_Decision__c, Reason_for_Appeal__c, Status__c, Denied_Case__r.CaseNumber
                            FROM Appeal__c
                            WHERE Denied_Case__r.AccountId = :veteran.Id AND Status__c NOT IN ('Closed', 'Decision Made')
                            ORDER BY CreatedDate DESC
                            LIMIT :pageSize OFFSET :((currentAppealsPage - 1) * pageSize)];
    }

    // Navigate to the next CLaim page
    public void nextPage(){
        if(currentClaimsPage * pageSize < totalClaims){
            currentClaimsPage++;
            updatePaginatedClaims();
        }
    }

    // Navigate to the next Appeal page
    public void nextAppealsPage(){
        if(currentAppealsPage * pageSize < totalAppeals){
            currentAppealsPage++;
            updatePaginatedAppeals();
        }
    }

    // Go to the previous Claim page
    public void previousPage() {
        if (currentClaimsPage > 1) {
            currentClaimsPage--;
            updatePaginatedClaims();
        }
    }

    // Go to the previous Appeal page
    public void previousAppealsPage() {
        if (currentAppealsPage > 1) {
            currentAppealsPage--;
            updatePaginatedAppeals();
        }
    }       

    // Check if "Next" button should be disabled
    public Boolean getDisableNext() {
        return (currentClaimsPage * pageSize >= totalClaims);
    }

    // Check if "Previous" button should be disabled
    public Boolean getDisablePrevious() {
        return (currentClaimsPage == 1);
    }

    // Check if "Next" button should be disabled
    public Boolean getDisableNextAppeals(){
        return (currentAppealsPage * pageSize >= totalAppeals);
    }

    // Check if "Previous" button should be disabled
    public Boolean getDisablePreviousAppeals() {
        return (currentAppealsPage == 1);
    }
  

    public PageReference redirectToFlow(){
        return new PageReference('https://awcomputing502--c.vf.force.com/flow/Veteran_Update_Request_Flow?recordId=' + veteran.Id);
        //return new PageReference('/flow/Veteran_Update_Request_Flow?recordId= ' + veteran.Id);
        // return new PageReference(getFlowUrl());
    }

    public String getFlowUrl(){
        String baseUrl = Site.getBaseUrl();
        String flowName = 'Veteran_Update_Request_Flow?recordId=';
        return baseUrl + '/flow/' + flowName + veteran.Id;
    }

}