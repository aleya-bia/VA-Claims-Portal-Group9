import { LightningElement, api } from 'lwc';

export default class AppealSubmissionFlowContainer extends LightningElement {
    @api flowName = 'Appeal_Submission'; // get correct flow

    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            console.log('Flow completed');
        }
    }
}