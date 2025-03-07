public with sharing class SetUserPassword {
    @InvocableMethod(label='Set User Password' description='Sets the password for a newly created user')
    public static void setPassword(List<SetPasswordRequest> requests) {
        for (SetPasswordRequest request : requests) {
            try {
                System.setPassword(request.userId, request.newPassword);
            } catch (Exception e) {
                System.debug('Error setting password: ' + e.getMessage());
            }
        }
    }
    
    public class SetPasswordRequest {
        @InvocableVariable(label='User ID' required=true)
        public String userId;
        
        @InvocableVariable(label='New Password' required=true)
        public String newPassword;
    }
}