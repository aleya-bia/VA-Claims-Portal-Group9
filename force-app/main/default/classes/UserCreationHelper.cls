public class UserCreationHelper {
    
    @InvocableMethod(label='Create User' description='Creates a new user asynchronously')
    public static void createUser(List<UserWrapper> userList) {
        // Convert the UserWrapper list to a JSON string for passing to the future method
        String userListJson = JSON.serialize(userList);
        
        // Call the future method to handle user creation asynchronously
        createUserAsync(userListJson);
    }

    // Future method to create user asynchronously
    @future
    public static void createUserAsync(String userListJson) {
        try {
            // Deserialize the JSON string back to a list of UserWrapper objects
            List<UserWrapper> userList = (List<UserWrapper>)JSON.deserialize(userListJson, List<UserWrapper>.class);

            // Fetch the Profile ID for the Experience Cloud user (replace with your Profile Name)
            Profile userProfile = [SELECT Id FROM Profile WHERE Name = 'Veterans' LIMIT 1];

            // Create the new User records
            List<User> usersToInsert = new List<User>();

            for (UserWrapper u : userList) {
                User newUser = new User(
                    FirstName = u.firstName,
                    LastName = u.lastName,
                    Email = u.email,
                    Username = u.username,
                    CommunityNickname = u.CommunityNickname,
                    Alias = u.alias,
                    ProfileId = userProfile.Id,
                    UserRoleId = '00E4U000001Mq9W', // Set the appropriate role ID here
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    IsActive = true,
                    Related_Veteran_Id__c = u.accountId // Store the related Account ID
                );

                usersToInsert.add(newUser);
            }

            // Insert the users asynchronously
            insert usersToInsert;

        } catch (Exception e) {
            System.debug('Error creating user: ' + e.getMessage());
        }
    }

    // Wrapper Class for Flow Input
    public class UserWrapper {
        @InvocableVariable(label='First Name' required=true)
        public String firstName;
        
        @InvocableVariable(label='Last Name' required=true)
        public String lastName;
        
        @InvocableVariable(label='Email' required=true)
        public String email;
        
        @InvocableVariable(label='Username' required=true)
        public String username;

        @InvocableVariable(label='Community Nickname' required=true)
        public String CommunityNickname;
        
        @InvocableVariable(label='Alias' required=true)
        public String alias;
        
        @InvocableVariable(label='Veteran ID' required=true)
        public String accountId;
    }
}