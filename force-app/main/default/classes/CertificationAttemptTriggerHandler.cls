public class CertificationAttemptTriggerHandler {

    public static void createCertificationHeld(List<Certification_Attempt__c> certAttempts, Map<Id, Certification_Attempt__c> oldMap) {

        /**
         * If a Contact successfully passes a Certification Attempt, then the code
         * will gather the data necessary to perform a query for related Certification
         * Attempt records.
         */

        System.Debug('Calling the createCertificationHeld method');

        // The sets of candidates and certifications are used to filter the
        // SOQL query when looking at existing cert attempt records
		
        // TODO #1: Declare and initialize Sets for candidates and certifications
        Set<Id> candidates = new Set<Id>();
        Set<Id> certifications = new Set<Id>();

        //Declare a variable that is a List of 
        List<Certification_Attempt__c> certAttemptsPass = new List<Certification_Attempt__c>();

         // Declare a variable of type map that uses the type String 
        Map<String, Integer> passCounts = new Map<String, Integer>();

        //Declare a variable of type Map that uses the type String 
        Map<String, Certification_Held__c> certsHeldToAdd = new Map<String, Certification_Held__c>();

        // Extract candidates and certifications from incoming records that have the status 'Complete/Pass'
        for(Certification_Attempt__c attempt : certAttempts){
            if ((attempt.Status__c == 'Complete/Pass' && (oldMap == null || oldMap.get(attempt.Id).Status__c != 'Complete/Pass'))){
                candidates.add(attempt.Certification_Candidate__c);
                certifications.add(attempt.Certification_Id__c);
                certAttemptsPass.add(attempt);
            }
        }

        // Query for Certification Attempts that are 'Complete/Pass' for the same candidate and certification
        for(List<Certification_Attempt__c> certAtts : [SELECT Id, Certification_Id__c, Certification_Candidate__c, Number_of_Elements_for_Cert__c
                                                FROM Certification_Attempt__c 
                                                WHERE Status__c = 'Complete/Pass' 
                                                AND Certification_Id__c IN :certifications AND Certification_Candidate__c IN :candidates]){

            // Loop through the Certification Attempts and create a map of the number of passes for each candidate and certification
            for(Certification_Attempt__c certAttempt : certAtts){
                System.debug('Retrieved Certification Attempt id: ' + certAttempt.Id + 
                            ' Candidate id: ' + certAttempt.Certification_Candidate__c + 
                            ' Certification id: ' + certAttempt.Certification_Id__c);

                // Create a key for the passCounts map
                String currentKey = certAttempt.Certification_Candidate__c + certAttempt.Certification_Id__c;

                // If the key already exists, increment the count
                if (passCounts.containsKey(currentKey)) {
                    passCounts.put(currentKey, (passCounts.get(currentKey) + 1));
                } else {
                    passCounts.put(currentKey, 1);
                }
            }   
        }
        // Print out the count of Certification Passes and the values of the passCounts map
        System.debug('Count of Certification Passes = ' + passCounts.size() + ', and its values are: ' + passCounts);

        //Create a for loop with an iterator of type Certification_Attempt__c named certAttempt that iterates over the certAttemptsPass variable.        
        for (Certification_Attempt__c certAtt : certAttemptsPass) {

            // If all certification elements are complete and if a certification held does not already exist
            String keyCurrent = certAtt.Certification_Candidate__c + certAtt.Certification_Id__c;
            if (passCounts.get(keyCurrent) == certAtt.Number_Of_Elements_For_Cert__c) {
                
                // Create a new certification held record
                Certification_Held__c certHeld  = new Certification_Held__c();
                certHeld.Date_Achieved__c       = certAtt.Attempt_Date__c;
                certHeld.Certification__c       = certAtt.Certification_Id__c;
                certHeld.Certified_Professional__c = certAtt.Certification_Candidate__c;
                certsHeldToAdd.put(keyCurrent,certHeld);
            }
        }

        // try-catch block to insert the certification held records. If the insert fails, the list is left empty but the error is logged via the Apex Error Logging framework.
        try {
            if (certsHeldToAdd.size() > 0 ) {
                insert certsHeldToAdd.values();
                System.debug('Adding '+ certsHeldToAdd.size() + ' record(s) for Certifications Held');
            }
        } catch (System.DmlException e) {
            Error_Log__c error = new Error_Log__c();
            error.Source__c = 'createCertificationHeld';
            error.message__c = e.getMessage();
            insert error;
        }
    }

    public static void grantInstructorSharingAccess(List<Certification_Attempt__c> triggerNew,
			Map<Id, Certification_Attempt__c> oldMap, Boolean isInsert, Boolean isUpdate) {

        /**
          *  When a new certification attempt object is assigned an
          *  instructor, or if an instructor changes on an existing
          *  object, give the new instructor access to the record by
          *  creating a share object, and remove access for the
          *  previous instructor (if it is an update of that field)
          */

        System.debug('Starting the Grant Instructor Sharing Access logic');

        // List of share records to insert in bulk
        List<Certification_Attempt__Share> sharesToCreate = new List<Certification_Attempt__Share>();

        // List of share records to delete in bulk
        List<Certification_Attempt__Share> sharesToDelete = new List<Certification_Attempt__Share>();

        // Map of the CertAttemptID to the Instructor User ID
        Map<Id, Id> certAttemptToInstructorMap = new Map<Id, Id>();

        // Loop through all the records in the trigger
        for (Certification_Attempt__c certAttempt : triggerNew) {

            // Check to see if this is an insert or the Instructor has changed
            if (isInsert || certAttempt.Certifying_Instructor__c != oldMap.get(certAttempt.Id).Certifying_Instructor__c) {
                // Create new Share record for the Instructor and add to list
                if (certAttempt.Certifying_Instructor__c != null) {
                    Certification_Attempt__Share certAttemptShare = new Certification_Attempt__Share(
                        parentId = certAttempt.Id,
                        userOrGroupId = certAttempt.Certifying_Instructor__c,
                        rowCause = Schema.Certification_Attempt__Share.RowCause.Certifying_Instructor__c,
                        accessLevel = 'Edit'
                    );
                    sharesToCreate.add(certAttemptShare);
                }
            }

            if (isUpdate) {
                // See the Instructor has changed
                if (certAttempt.Certifying_Instructor__c != oldMap.get(certAttempt.Id).Certifying_Instructor__c) {
                    // Add to map of Instructor changes
                    System.debug('certAttempt.Certifying_Instructor__c is: ' + certAttempt.Certifying_Instructor__c);
                    certAttemptToInstructorMap.put(certAttempt.Id, certAttempt.Certifying_Instructor__c);
                }
            }
        }

        if (certAttemptToInstructorMap.size() > 0) {

            System.debug('certAttemptToInstructorMap is: ' + certAttemptToInstructorMap);

            for (Certification_Attempt__Share certAttemptShare :
						[SELECT UserOrGroupId, RowCause, ParentId, Id, AccessLevel
						   FROM Certification_Attempt__Share
						  WHERE ParentId IN :certAttemptToInstructorMap.keySet()
							AND RowCause = 'Certifying_Instructor__c']) {
                if (certAttemptToInstructorMap.get(certAttemptShare.ParentId) != certAttemptShare.UserOrGroupId) {
                    sharesToDelete.add(certAttemptShare);
                }
            }
        }

        try {
            if ( sharesToCreate.size() > 0 ) {
                insert sharesToCreate;
            }
            if ( sharesToDelete.size() > 0) {
                delete sharesToDelete;
            }
        } catch (System.DmlException ex) {
            Error_Log__c err = new Error_Log__c();
            err.Source__c = 'grantInstructorSharingAccess';
            err.message__c = ex.getMessage();
            insert err;
        }
    }

    public static void validateCertificationAttempt(List<Certification_Attempt__c> triggerNew) {

        /**
         *  If a Contact is trying to create a Certification Attempt
         *  for an element that was already marked as "Complete/Pass"
         *  or "In Progress", then do not allow the attempt to be
         *  created and pass back an error
         */

        System.debug('Starting the Validate Certification Attempt logic');

        // All Certification_Attempt__c records which are 'In Progress' OR 'Complete/Pass' will be stored here for comparison purposes
        Set<String> concatStudentElement = new Set<String>();
                Set<ID> candidateIDs = new Set<ID>();
        for (Certification_Attempt__c dbca : triggerNew) {
            candidateIDs.add(dbca.Certification_Candidate__c);
        }
        for (Certification_Attempt__c dbca : [SELECT Certification_Candidate__c, Certification_Element__c, Status__c
                                               FROM Certification_Attempt__c
                                              WHERE Status__c IN ('In Progress', 'Complete/Pass')
                                                AND Certification_Candidate__c IN :candidateIDs]) {
            // We need to know 1. Which student 2. Which element they have attempted (lab or multiple choice) 3. The status
            concatStudentElement.add((String)dbca.Certification_Candidate__c + (String)dbca.Certification_Element__c + (String)dbca.Status__c);
        }

        for (Certification_Attempt__c ca : triggerNew) {
            // If any element is In Progress or Complete/Pass, new attempts should not be allowed for those elements
            if (concatStudentElement.contains((String)ca.Certification_Candidate__c + (String)ca.Certification_Element__c + 'In Progress') ||
                concatStudentElement.contains((String)ca.Certification_Candidate__c + (String)ca.Certification_Element__c + 'Complete/Pass')) {
                   ca.addError('Cannot attempt cert for element already in progress or completed');
            }
        }
    }
}