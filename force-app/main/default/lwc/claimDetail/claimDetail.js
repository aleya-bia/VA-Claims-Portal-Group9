import { LightningElement, wire, api} from 'lwc';
import getClaimDetails from '@salesforce/apex/ClaimsAndAppealsController.getClaimDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFiles from '@salesforce/apex/ClaimsAndAppealsController.getFiles';

export default class ClaimDetail extends LightningElement {
    @api claimId;   // Received from parent component claimsDataPage
    claim;
    files = [];     // Holds uploaded files

    // Fetch claim details
    @wire(getClaimDetails, { claimId: '$claimId'})
    wireClaim( {error, data}){
        if (data){
            this.claim = data;
            this.currentStatus = this.claim.Status;
        } else if( error ){
            console.error('Error fatching claim details: ', error);
        }
    }

    // Fetch uploaded files 
    @wire(getFiles, {recordId: '$claimId'})
    wireFiles({error, data}){
        if (data){
            this.files = data;
        } else if (error){
            console.error('Error fatching files: ', error);
        }
    }

    // Handle File Upload Success
    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        this.showToast('Success', 'File(s) uploaded','success');

    }

    // Show Toast Message
    showToast(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}