import { LightningElement, api, track } from 'lwc';

import saveAgreementSignature from '@salesforce/apex/CheckoutController.saveAgreementSignature';

export default class CheckoutSignature extends LightningElement {
    @api subscription;
    @api showAgreementBeforeSubmit;

    @api validate() { return this.validateSignature() }
    @api save() { return this.saveSignature() }

    @track signatureSaved = false;
    @track agreementAccepted = false;

    get signatureUrl() { return this.subscription.SignatureURL__c }

    handleAgreementAccepted(event) { this.agreementAccepted = event.detail.checked; }

    validateSignature() {
        return new Promise((resolve, reject) => {
            if (this.template.querySelector('c-signature-pad').isEmpty()) {
                reject(['A signature is required']);
            }
            if (!this.agreementAccepted) {
                reject(['You must agree to the terms of service'])
            }
            resolve();
        });
    }

    saveSignature() {
        let _this = this;
        return new Promise((resolve, reject) => {
            
            if (!_this.showAgreementBeforeSubmit || _this.signatureSaved || _this.signatureUrl) {
                resolve();
                return;
            }
            saveAgreementSignature({ subId: _this.subscription.Id, signatureUrl: _this.template.querySelector('c-signature-pad').toDataURL() })
                .then(() => {
                    _this.signatureSaved = true;
                    resolve();
                })
                .catch(() => reject(['Failed to update the agreement']))
        });
    }
}