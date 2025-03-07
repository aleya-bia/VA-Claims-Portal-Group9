import { LightningElement } from 'lwc';

export default class ClaimsDataPage extends LightningElement {
    selectedClaimId;
    selectedAppealId;

    // Event handler to update the selected Claim ID
    handleClaimSelection(event) {
        this.selectedClaimId = event.detail.claimId;
    }

    // Capture event from `appealsList`
    handleAppealSelection(event) {
        this.selectedAppealId = event.detail.appealId;
    }
}