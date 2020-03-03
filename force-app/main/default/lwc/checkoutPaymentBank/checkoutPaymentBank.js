import { LightningElement, api, track } from 'lwc';

export default class PaymentInformation extends LightningElement {
    @track bankInformation = {nameOnAccount: '', accountType: 'checking', routingNumber: '', accountNumber: '', accountNumberConfirmation: ''};
    @track accountTypeOptions = [{label: 'Checking', value: 'checking'}, {label: 'Savings', value: 'savings'}];

    @api validate() { return this.validateBankInformation() }
    @api 
    get nameOnAccount() { return this.bankInformation.nameOnAccount } 
    set nameOnAccount(value) { this.bankInformation.nameOnAccount = value }

    handleChange(event) { this.updateField(event) }

    updateField(event) {
        this.bankInformation[event.target.name] = event.target.value;
        const selectedEvent = new CustomEvent('bankchanged', { detail: this.bankInformation });
        this.dispatchEvent(selectedEvent);
    }

    validateBankInformation() {
        return new Promise((resolve, reject) => {
            if (!this.template.querySelector('[data-id="nameOnAccount"]').reportValidity()) {
                reject('Invalid name on account');
            } else if (!this.template.querySelector('[data-id="accountType"]').reportValidity()) {
                reject('Invalid account type');
            } else if (!this.template.querySelector('[data-id="routingNumber"]').reportValidity()) {
                reject('Invalid routing number');
            } else if (!this.template.querySelector('[data-id="accountNumber"]').reportValidity()) {
                reject('Invalid account number');
            } else if (!this.template.querySelector('[data-id="accountNumberConfirmation"]').reportValidity()) {
                reject('Invalid account number confirmation');
            } else if (this.bankInformation.accountNumber !== this.bankInformation.accountNumberConfirmation) {
                reject('Account number does not match');
            }else {
                resolve();
            }
        });
    }
}