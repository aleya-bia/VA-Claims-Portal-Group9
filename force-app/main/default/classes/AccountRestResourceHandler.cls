public with sharing class AccountRestResourceHandler {
    public AccountRestResourceHandler() {

    }

    public static List<Account> getAllAccounts() {
        return [SELECT Id, Name FROM Account];
    }

    public static List<Account> getAccountsAndContactById(String accountId) {
        return [SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WHERE Id = :accountId];
    }

    public static List<Account> getAccountsById(String accountId) {
        return [SELECT Id, Name FROM Account WHERE Id = :accountId];
    }

    public static Account createAccount(String name, String phone) {
        Account acc = new Account(Name = name, Phone = phone);
        insert acc;
        return acc;
    }

    public static void updateAccount(String id, String name, String phone) {
        
        Account acc = [SELECT Id, Name, Phone FROM Account WHERE id = :id];

        acc.Name = name;
        acc.phone = phone;

        update acc;
    }

    public static void deleteAccount(String id) {
        
        Account acc = [SELECT Id FROM Account WHERE id = :id];

        delete acc;
    }
}