public class CustomerInfoDTO {
     /*
     Data Transfer Object (DTO)
        - DTO is a design pattern used to transfer data between software application subsystems.
        - DTOs are often used in conjunction with data access objects to retrieve data from a database.
        - transform data feom how it looks in the database to how it looks in the request/response
        - DTO should match how the data looks in the request/response
        - then you map the data to some existing object in your database
    */

    Integer customerID; // attribute need to be the same as they are in the JSON
    String createdOn;
    String firstName;
    String middleInitial;
    String lastName;
    String dob;
    String address;
    String city;
    String state;
    String zipCode;
    String phoneNumber;
    String email;
    String lastLoginDate;
    String lastTaxFilingDate;
    Boolean auditFlag;

    public CustomerInfoDTO(String createdOn, String firstName, String middleInitial, String lastName, 
            String dob, String address, String city, String state, String zipCode, String phoneNumber, String email, 
            String lastLoginDate, String lastTaxFilingDate, Boolean auditFlag) {

        this.createdOn = createdOn;
        this.firstName = firstName;
        this.middleInitial = middleInitial;
        this.lastName = lastName;
        this.dob = dob;
        this.address = address;
        this.city = city;
        this.state = state;
        this.zipCode = zipCode;
        this.phoneNumber = phoneNumber;
        this.email = email;
        this.lastLoginDate = lastLoginDate;
        this.lastTaxFilingDate = lastTaxFilingDate;
        this.auditFlag = auditFlag;

    }
/*
    //DTO contain som mapping method
    public Customer dtoToCustomer(){
        // map customer infor dto -> regular customer object
        //return created customer
    }

    public Customer customerToDto(){
        // map regular customer object -> customer info dto
        //return created dto
    }*/
}