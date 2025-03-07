trigger ErrorMessageTrigger on Error_Message__e (after insert) {

    List<Error_Log__c> errs = new List<Error_Log__c>();
    
    // TODO #1:  Loop through trigger.new and create Error_Log__c records 
    //   for each platform event and add to the errs list
    for(Error_Message__e error : Trigger.new){
        errs.add(new Error_Log__c(
            Message__c = error.Message__c,
            Source__c = error.Source_Component__c
        ));
        
    }

    insert errs;
}