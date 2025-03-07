@isTest
public class ClaimsAndAppealsControllerTest {

    // private static User testUser;
    // private static Account testVeteran;
    // private static Case testClaim;
    // private static Appeal__c testAppeal;
    // private static ContentVersion testFile;
    // private static ContentDocumentLink testFileLink;


    @testSetup
    static void setupTestData(){

        // Create a test Veteran 
        Account testVeteran = new Account(Name = 'Jonhn Doe');
        insert testVeteran;

        // Create a test User Linked to Veteran
        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'johndoe@example.com',
            Username = 'johndoe@exampleVeteran.com.test',
            Alias = 'jdoe',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Related_Veteran_Id__c = testVeteran.Id
        );
        insert testUser;

        // Assign the test user to running test context
        System.runAS(testUser){
            // Create a test Claim
            Case testClaim = new Case(
                AccountId = testVeteran.Id,
                Subject = 'This is a test claim',
                Status ='Under Review',
                Claim_Type__c = 'Disability'
            );
            insert testClaim;

            // Create a test Appeal linked to the Denied Claim
            Appeal__c testAppeal = new Appeal__c(
                Denied_Case__c = testClaim.Id,
                Reason_for_Appeal__c = 'This is a test appeal',               
                Status__c = 'Received',
                Appeal_Type__c = 'In-Person Hearing'
            );
            insert testAppeal;

            // Create a test File (ContentDocument)
            ContentVersion testFile = new ContentVersion(
                Title = 'VA Benefit Document',
                PathOnClient = 'VABenefitDoc.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert testFile;

            List<ContentDocument> docs = [SELECT Id, Title  FROM ContentDocument];

            ContentDocumentLink testFileLink = new ContentDocumentLink(
                LinkedEntityId = testClaim.Id,
                ContentDocumentId = docs[0].Id,
                ShareType = 'I'
            );
            insert testFileLink;
        }
    }

    // Test: Get Veteran Account Id
    @isTest 
    static void testGetLoggedInVeteranAccountID(){
        User testUser2 = [
            SELECT Id, Related_Veteran_Id__c 
            FROM User WHERE Username = 'johndoe@exampleVeteran.com.test' LIMIT 1];
        
        System.runAs(testUser2){
            Test.startTest();
                Id veteranID = ClaimsAndAppealsController.getLoggedInVeteranAccountId();
            Test.stopTest();

            System.assertNotEquals(null, veteranID, 'Expected at least 1 claim.');
        }
    }

    // 🛠️ Test: Get Veteran Claims
    @isTest
    static void testGetVeteranClaims() {
        User testUser2 = [
            SELECT Id, Related_Veteran_Id__c 
            FROM User WHERE Username = 'johndoe@exampleVeteran.com.test' LIMIT 1];

        System.runAs(testUser2) {
            Test.startTest();
            List<Case> claims = ClaimsAndAppealsController.getVeteranClaims();
            Test.stopTest();
    
            System.assertNotEquals(0, claims.size(), 'Expected at least 1 claim.');
            
        }
    }
        
    
    // 🛠️ Test: Get Claim Details
    @isTest
    static void testGetClaimDetails() {

        Case testClaim = [
            SELECT Id, Status
            FROM Case
            WHERE  Subject = 'This is a test claim'
        ];

        Test.startTest();
        Case claim = ClaimsAndAppealsController.getClaimDetails(testClaim.Id);
        Test.stopTest();

        System.assertNotEquals(null, claim, 'Expected at least 1 claim.');
    }

        // 🛠️ Test: Get Claim Details with Null
    @isTest
    static void testGetClaimDetails_Null() {

        Id claimId; 

        Test.startTest();
        Case claim = ClaimsAndAppealsController.getClaimDetails(claimId);
        Test.stopTest();

        System.assertEquals(null, claim, 'Should return Null');
    }

    // // 🛠️ Test: Get Veteran Appeals
    @isTest
    static void testGetVeteranAppeals() {

        User testUser2 = [
            SELECT Id, Related_Veteran_Id__c 
            FROM User WHERE Username = 'johndoe@exampleVeteran.com.test' LIMIT 1
        ];

        System.runAs(testUser2){
            Test.startTest();
            List<Appeal__c> appeals = ClaimsAndAppealsController.getVeteranAppeals();
            Test.stopTest();
    
            System.assertNotEquals(0, appeals.size(), 'Expected at least 1 appeal.');
        }

        
    }

    // 🛠️ Test: Get Appeal Details
    @isTest
    static void testGetAppealDetails() {

        Appeal__c testApeal = [
            SELECT Id
            FROM Appeal__c
        ];

        Test.startTest();
        Appeal__c appeal = ClaimsAndAppealsController.getAppealDetails(testApeal.Id);
        Test.stopTest();

        System.assertNotEquals(null, appeal, 'Expected at least 1 appeal.');

    }

    // 🛠️ Test: Get Appeal Details weith Null
    @isTest
    static void testGetAppealDetails_Null() {

        Id appealId;

        Test.startTest();
        Appeal__c appeal = ClaimsAndAppealsController.getAppealDetails(appealId);
        Test.stopTest();

        System.assertEquals(null, appeal, 'Should return Null.');

    }

    // 🛠️ Test: Get Files for a Claim
    @isTest
    static void testGetFiles() {

        Case testClaim = [
            SELECT Id, Status
            FROM Case
            WHERE  Subject = 'This is a test claim'
        ];

        Test.startTest();
        List<Map<String, String>> files = ClaimsAndAppealsController.getFiles(testClaim.Id);
        Test.stopTest();

        System.assertNotEquals(0, files.size(), 'Expected at least 1 file linked to the claim.');
    }

    @isTest 
    static void testgetClaimsAndAppealsOverview(){
        User testUser2 = [
            SELECT Id, Related_Veteran_Id__c 
            FROM User WHERE Username = 'johndoe@exampleVeteran.com.test' LIMIT 1
            ];
            
        System.runAs(testUser2){
            Test.startTest();
                List<Map<String, String>> claimsNApeals = ClaimsAndAppealsController.getClaimsAndAppealsOverview();
            Test.stopTest();

            System.assertNotEquals(0, claimsNApeals.size(), 'Expected at least 1 claim or appeal.');
        }
    }


}