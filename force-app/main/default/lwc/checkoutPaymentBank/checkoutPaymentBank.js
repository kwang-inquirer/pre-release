import { LightningElement, api, track } from 'lwc';

export default class PaymentInformation extends LightningElement {
    @track _payment;
    @api subscription;
    @api accountTypeOptions = [{label: 'Checking', value: 'checking'}, {label: 'Savings', value: 'savings'}];

    @api
    get payment() { return this._payment }
    set payment(payment) { this._payment = { ...payment } }

    @api validate() { return this.validatePayment() }

    handleChange(event) { this.updateField(event) }

    updateField(event) {
        this._payment[event.target.name] = event.target.value;
        this.paymentChanged();
    }

    validatePayment() {
        return new Promise((resolve, reject) => {
            if (!this.template.querySelector('[data-id="routingNumber"]').reportValidity()) {
                reject();
            }
            if (!this.template.querySelector('[data-id="accountNumber"]').reportValidity()) {
                reject();
            }
            if (!this.template.querySelector('[data-id="accountType"]').reportValidity()) {
                reject();
            }
            resolve();
        });
    }

    paymentChanged() {
        const selectedEvent = new CustomEvent('paymentchanged', { detail: this.payment });
        this.dispatchEvent(selectedEvent);
    }
}