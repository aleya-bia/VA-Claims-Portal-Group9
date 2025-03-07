// Import necessary modules and Apex methods for retrieving claims and appeals data
import { LightningElement, wire } from 'lwc';
import getOpenClaims from '@salesforce/apex/ClaimsController.getOpenClaims';
import getOpenAppeals from '@salesforce/apex/AppealsController.getOpenAppeals';
import getClosedClaims from '@salesforce/apex/ClaimsController.getClosedClaims';
import getClosedAppeals from '@salesforce/apex/AppealsController.getClosedAppeals';

export default class DashboardHomePage extends LightningElement {
    // Declare properties to hold counts of claims and appeals
    openClaimsCount = 0;
    openAppealsCount = 0;
    closedClaimsCount = 0;
    closedAppealsCount = 0;
    hasClaimsOrAppeals = false;  // Flag to check if there are any claims or appeals

    // Wire method to get open claims and update count
    @wire(getOpenClaims)
    wiredOpenClaims({ error, data }) {
        if (data) {
            this.openClaimsCount = data;
            this.checkClaimsOrAppeals();  // Check if there are any claims or appeals
        } else if (error) {
            console.error('Error fetching open claims', error);  // Log error if fetching fails
        }
    }

    // Wire method to get open appeals and update count
    @wire(getOpenAppeals)
    wiredOpenAppeals({ error, data }) {
        if (data) {
            this.openAppealsCount = data;
            this.checkClaimsOrAppeals();
        } else if (error) {
            console.error('Error fetching open appeals', error);
        }
    }

    // Wire method to get closed claims and update count
    @wire(getClosedClaims)
    wiredClosedClaims({ error, data }) {
        if (data) {
            this.closedClaimsCount = data;
            this.checkClaimsOrAppeals();
        } else if (error) {
            console.error('Error fetching closed claims', error);
        }
    }

    // Wire method to get closed appeals and update count
    @wire(getClosedAppeals)
    wiredClosedAppeals({ error, data }) {
        if (data) {
            this.closedAppealsCount = data;
            this.checkClaimsOrAppeals();
        } else if (error) {
            console.error('Error fetching closed appeals', error);
        }
    }

    // Method to check if there are any claims or appeals
    checkClaimsOrAppeals() {
        this.hasClaimsOrAppeals = (this.openClaimsCount > 0 || this.closedClaimsCount > 0 || this.openAppealsCount > 0 || this.closedAppealsCount > 0);
    }
}