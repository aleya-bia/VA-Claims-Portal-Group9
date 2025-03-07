import { LightningElement } from 'lwc';

export default class RegistrationButton extends LightningElement {
    isModalOpen = false;

    // Handle the button click to open the modal with the flow
    handleClick() {
        this.isModalOpen = true;
    }

    // Handle the closing of the flow modal (if needed)
    handleStatusChange(event) {
        if (event.detail.status === 'FINISHED') {
            this.isModalOpen = false;
        }
    }
}