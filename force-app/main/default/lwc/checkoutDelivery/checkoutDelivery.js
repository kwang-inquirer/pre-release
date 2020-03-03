import { LightningElement, api, track } from 'lwc';

import saveDeliveryAddress from '@salesforce/apex/CheckoutController.saveDeliveryAddress';
import hasValidDeliveryAddress from '@salesforce/apex/CheckoutController.hasValidDeliveryAddress';

export default class CheckoutDelivery extends LightningElement {
    @track errors;
    @track _address;
    @track _country = 'US';
    @track loading = false;

    @api subscription = {};

    @api
    get address() { return this._address; }
    set address(address) { this._address = { ...address }; }

    get hasErrors() { return this.errors && this.errors.length > 0; }

    handleNextClicked() { this.save(); }

    handleAddressChange(event) {
        this.address = event.detail;
    }

    handleNameChange(event) {
        this.address[event.target.name] = event.target.value;
    }

    save() {
        this.errors = null;
        this.loading = true;
        this.validateAddress()
            .then(() => this.saveAddress())
            .then(() => this.onSaveAddressSuccess())
            .catch(errors => this.onSaveAddressError(errors ? errors : ['Failed to save the address']))
    }

    validateAddress() {
        return this.template.querySelector('c-checkout-address').validate();
    }

    saveAddress() {
        const saveParams = { subId: this.subscription.Id, address: this.address };
        const validateParams = { subId: this.subscription.Id };
        return new Promise((resolve, reject) => {
            saveDeliveryAddress(saveParams)
                .then(() => {
                    this.retry(hasValidDeliveryAddress, validateParams)
                        .then(valid => {
                            if (!valid) {
                                reject(['Address is not deliverable']);
                            } else {
                                resolve();
                            }
                        })
                        .catch(() => {
                            reject(['Failed to validate the address']);
                        })
                })
                .catch(errors => { reject(errors || ['Failed to save the address']) })
        });
    }
//
    onSaveAddressSuccess() {
        this.loading = false;
        const selectedEvent = new CustomEvent('next', { detail: this.address });
        this.dispatchEvent(selectedEvent);
    }

    onSaveAddressError(errors) {
        this.loading = false;
        this.errors = (errors) ? errors : ['Failed to save the address'];
    }

    retry(fn, params, retriesLeft = 10, interval = 1000) {
        return new Promise((resolve, reject) => {
            fn(params)
                .then(resolve)
                .catch((error) => {
                    setTimeout(() => {
                        if (retriesLeft === 1) {
                            reject(error);
                            return;
                        }
                        this.retry(fn, params, interval, retriesLeft - 1).then(resolve, reject);
                    }, interval);
                });
        });
    }
}