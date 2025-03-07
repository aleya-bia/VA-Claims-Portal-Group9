import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getClaimsAndAppealsOverview from '@salesforce/apex/ClaimsAndAppealsController.getClaimsAndAppealsOverview';

export default class ClaimsAndAppealsOverview extends NavigationMixin(LightningElement) {
    claimsAndAppeals;
    hasClaimsAndAppeals = false;
    isLoading = true;

    // Column configuration for the datatable
    columns = [
        { label: 'Type', fieldName: 'type' },
        { label: 'Name', fieldName: 'url', type: 'button', typeAttributes: { label: { fieldName: 'name' }, name: 'navigate', variant: 'base' } },
        { label: 'Status', fieldName: 'status' }
    ];

    // Fetch the Claims and Appeals data
    @wire(getClaimsAndAppealsOverview)
    wiredClaimsAndAppeals({ error, data }) {
        if (data) {
            this.claimsAndAppeals = data;
            this.hasClaimsAndAppeals = data.length > 0;
            this.isLoading = false;
        } else if (error) {
            console.error('Error fetching Claims and Appeals data', error);
            this.isLoading = false;
        }
    }

    // Handle the button click to navigate
    handleRowAction(event) {
        const row = event.detail.row;
        const recordUrl = row.url;

        if (recordUrl) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: recordUrl
                }
            });
        }
    }
}