/*
    RESt RESOURCE
        - signals that this class handles REST HTTP reequests
        - class and methods needs to be global
        - the urlMappping will match to anything after the base url of you org
            - base url: <domain-name>/services/apexrest/
*/
@RestResource(urlMapping='/accounts/*')
global with sharing class AccountRestResource {
    /*
    HttpGet
        - this method handles All get requests sent to the urlMapping above
        - handles (because we added /* wildcard to the urlmapping):
            - /accounts
            - /accounts/contacts
            - /accounts/{id}/contact/cases

            - programmatically you have to parse through the request to determine the proper endpoint

    */
    //@HttpGet
    global static List<Account> getAccounts() {

        /*
            PROBLEMS WITH THIS METHOD
            - possibly hit governor limits
            - no error handling
            - we are returning sObject data directly, NOT setting a proper response
                - WHICH WORKS FINE, BUT is nor a best practice
                - user Rest Response instead
                    - if your methods have a return statement, the return will overide the set reposnse
            - this class is handling business logic itself
                -REST RESOURCE should only do "traffic cop logic" (same as triggers)
                - business logic should be moved to handler class

        */

        return [SELECT Id, Name FROM Account];
    }

    //return void bc the restresponse will automatically be returned. a regular statement would iverride it
    @HttpGet
    global static void getAccountsBetter() {

        //RestContext provides info on the current context of the incoming request and response
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        //determining endpoint of request
        String domain = request.requestURI.substringAfterLast('/');  // gives the last domain

        switch on domain {
            when 'accounts' {
                try{
                    List<Account> accounts = AccountRestResourceHandler.getAllAccounts();
                    response.responseBody = Blob.valueOf(JSON.serialize(accounts));
                    response.headers.put('Content-Type', 'application/json');
                    response.statusCode = 200;
                }catch(Exception e) {
                    //handle any errors that occur
                    response.responseBody = Blob.valueOf('Unable to retrieve accounts');
                    response.statusCode = 500;
                }
            } when 'contacts'{
                try{
                    String accountId = request.requestURI.substringBetween('accounts/', '/contacts');
                    List<Account> accounts = AccountRestResourceHandler.getAccountsAndContactById(accountId);
                    response.responseBody = Blob.valueOf(JSON.serialize(accounts));
                    response.headers.put('Content-Type', 'application/json');
                    response.statusCode = 200;
                }catch(Exception e) {
                    //handle any errors that occur
                    response.responseBody = Blob.valueOf('Unable to retrieve accounts');
                    response.statusCode = 500;
                }
            } when else{
                try{
                    List<Account> accounts = AccountRestResourceHandler.getAccountsById(domain);
                    response.responseBody = Blob.valueOf(JSON.serialize(accounts));
                    response.headers.put('Content-Type', 'application/json');
                    response.statusCode = 200;
                }catch(Exception e) {
                    //handle any errors that occur
                    response.responseBody = Blob.valueOf('Unable to retrieve accounts');
                    response.statusCode = 500;
                }
            }

        }
    }

    // method aruments are going to be automatically set by the Request body. ensure ...
    @HttpPost
    global static void createAccount(String name, String phone) {
        //RestContext provides info on the current context of the incoming request and response
        RestResponse response = RestContext.response;
        try{
            Account acc = AccountRestResourceHandler.createAccount(name, phone);
            response.responseBody = Blob.valueOf(JSON.serialize(acc));
            response.headers.put('Content-Type', 'application/json');
            response.statusCode = 201; //setting creates status
        } catch (DmlException e){

            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to creats account. Check data that was sent in request.');
            response.statusCode = 400;
        }
        catch (Exception e){
            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to create account.');
            response.statusCode = 500;
        }
    }

    @HttpPut
    global static void updateAccount(String id, String name, String phone) {
        //with updates, its common that id might be  apatch variab;e or query param, alternative to haveing id in request body
        RestResponse response = RestContext.response;
        try{
            AccountRestResourceHandler.updateAccount(id, name, phone);
            response.statusCode = 204; //setting NO CONTENT status
        } catch (QueryException e){

            //handle any errors that occur if account couldnt be located
            response.responseBody = Blob.valueOf('Unable to update account.');
            response.statusCode = 404; //NOT FOUND
        }
        catch (DmlException e){

            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to update account. Check data that was sent in request.');
            response.statusCode = 400; //BAD REQUEST
        }
        catch (Exception e){
            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to update account.');
            response.statusCode = 500;
        }
    }

    @HttpDelete
    global static void deleteAccount() {
        //with updates, its common that id might be  apatch variab;e or query param, alternative to haveing id in request body
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        //determining endpoint of request
        String id = request.requestURI.substringAfterLast('/'); 
        try{
            AccountRestResourceHandler.deleteAccount(id);
            response.statusCode = 204; //setting NO CONTENT status
        } catch (QueryException e){

            //handle any errors that occur if account couldnt be located
            response.responseBody = Blob.valueOf('Unable to find account.');
            response.statusCode = 404; //NOT FOUND
        }
        catch (DmlException e){

            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to delete account. Check data that was sent in request.');
            response.statusCode = 400; //BAD REQUEST
        }
        catch (Exception e){
            //handle any errors that occur
            response.responseBody = Blob.valueOf('Unable to delete account.');
            response.statusCode = 500;
        }
    }
}