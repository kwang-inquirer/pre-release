import { LightningElement, track, api } from 'lwc';
 
export default class AddressConfirmationModal extends LightningElement {
    @track showModal = false;
    @track address;

    @api 
    show(address) {
        this.address = address;
        this.showModal = true;
    }

    get addressAvailable() {
        return this.address;
    }

    closeModal() {
        this.address = {};
        this.showModal = false;
    } 

    applyClicked() {
        const selectedEvent = new CustomEvent('apply', { detail: this.address });
        this.dispatchEvent(selectedEvent);
        this.closeModal();
    }
}