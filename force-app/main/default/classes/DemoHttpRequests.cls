public with sharing class DemoHttpRequests {
    public DemoHttpRequests() {

    }

    
    public void getCustomers() {
        HttpRequest req = new HttpRequest();
        //setting the endpoint
        req.setEndpoint('callout:Appian_Customer_Named_Credentials/tax-customer');
        //setting the method
        req.setMethod('GET');
        //send off the http request
        Http http = new Http();
        //capturing response for http request
        HTTPResponse resp = http.send(req);

        Integer statusCode = resp.getStatusCode();
        if(statusCode == 200) {
            //proccessing the response, handle success
            System.debug(resp.getStatusCode());
            System.debug(resp.getStatus());
           // System.debug(resp.getBody());

            List<CustomerInfoDTO> customers = (List<CustomerInfoDTO>) JSON.deserialize(resp.getBody(), List<CustomerInfoDTO>.class);
            for(CustomerInfoDTO customer: customers) {
                System.debug(customer);
            }

        } else if (statusCode == 400) {
            //handle clianet side error
            System.debug('Error: ' + resp.getStatusCode());
        } else if(statusCode == 500) {
            //handle server side error
            System.debug('Error: ' + resp.getStatusCode());
        }
    }

    public void createCustomer(CustomerInfoDTO customerInfo) {
        HttpRequest req = new HttpRequest();
        //setting the endpoint
        req.setEndpoint('callout:Appian_Customer_Named_Credentials/tax-customer');
        //setting the method
        req.setMethod('POST');
        req.setBody(JSON.serialize(customerInfo)); //converting apec -> JSON so it can be sent in request

        //send off the http request
        Http http = new Http();
        //capturing response for http request
        HTTPResponse resp = http.send(req);

        Integer statusCode = resp.getStatusCode();
        if(statusCode == 201) {
            //proccessing the response, handle success
            System.debug('SUCCESS: ' + resp.getBody());

        } else if (statusCode == 400) {
            //handle clianet side error
            System.debug('Error: ' + resp.getBody());
        } else if(statusCode == 500) {
            //handle server side error
            System.debug('Error: ' + resp.getBody());
        }
    }
}