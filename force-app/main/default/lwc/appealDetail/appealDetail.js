import { LightningElement, api, wire } from 'lwc';
import getAppealDetails from '@salesforce/apex/ClaimsAndAppealsController.getAppealDetails';
import getFiles from '@salesforce/apex/ClaimsAndAppealsController.getFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AppealDetail extends LightningElement {
    @api appealId;
    appeal = null;
    files = [];

    // Fetch appeal details
    @wire(getAppealDetails, { appealId: '$appealId' })
    wiredAppeal({ error, data }) {
        if (data) {
            console.log("data has been received");
            this.appeal = data;
            this.currentStatus = this.appeal.Status__c;
        } else if (error) {
            console.log('nothing is received');
            console.error('Error fetching appeal details:', error);
        }
    }

    // Fetch uploaded files
    @wire(getFiles, { recordId: '$appealId'})
    wiredFiles({ error, data }) {
        if (data) {
            this.files = data;
        } else if (error) {
            console.error('Error fetching files:', error);
        }
    }


    // Handle File Upload Success
    handleUploadedFinished(event){
        const uploadedFiles = event.detail.files;
        this.showToast('Success', 'File(s) uploaded successfully.', 'success');
    }

    // Show Toast Message
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


}