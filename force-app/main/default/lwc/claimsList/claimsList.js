import { LightningElement, wire } from 'lwc';
import getVeteranClaims from '@salesforce/apex/ClaimsAndAppealsController.getVeteranClaims';

export default class ClaimsList extends LightningElement {
    claims = [];
    selectedClaimId;

    // Fetch Claims using Apex
    @wire(getVeteranClaims)
    wiredClaims( {error, data} ){
        if(data){
            this.claims = data;
        } else if (error){
            console.error('Error fetching claims: ', error);
        }
    }

    // Handle Claim Selection
    handleClaimSelect(event){
        this.selectedClaimId = event.currentTarget.dataset.id;

        console.log("click");
        console.log("ID is = ", this.selectedClaimId);
        
        this.dispatchEvent(new CustomEvent('claimselect', {
            detail: { claimId: this.selectedClaimId }
        }));
    }

}