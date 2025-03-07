import { LightningElement, wire } from 'lwc';
import getVeteranAppeals from '@salesforce/apex/ClaimsAndAppealsController.getVeteranAppeals';

export default class AppealsList extends LightningElement {
    appeals = [];

    @wire(getVeteranAppeals)
    wiredAppeals({ error, data }) {
        if (data) {
            this.appeals = data;
        } else if (error) {
            console.error('Error fetching appeals:', error);
        }
    }

    handleAppealSelect(event) {
        const selectedAppealId = event.currentTarget.dataset.id;

        console.log("AppealId is ", selectedAppealId);

        // Dispatch event to notify `claimsDataPage`
        this.dispatchEvent(new CustomEvent('appealselect', {
            detail: { appealId: selectedAppealId }
        }));
    }
}