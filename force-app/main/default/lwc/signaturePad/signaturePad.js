import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import signaturePadURL from '@salesforce/resourceUrl/signaturePad';

export default class SignaturePad extends LightningElement {
    signaturePad;
    sigPadInitialized = false;

    @api title = 'Signature';
    @api signatureUrl;

    @api isEmpty() { return this.signaturePad.isEmpty(); }
    @api toDataURL() { return this.signaturePad.toDataURL(); }

    renderedCallback() {
        if (this.sigPadInitialized) {
            return;
        }
        this.sigPadInitialized = true;

        Promise.all([loadScript(this, signaturePadURL)])
            .then(() => {
                this.initialize();
            })
    }

    initialize() {
        const canvas = this.template.querySelector('canvas.signature-pad');
        canvas.style.width = '100%';
        canvas.width = canvas.offsetWidth;
        this.signaturePad = new window.SignaturePad(canvas);
        if (this.signatureUrl) {
            this.signaturePad.fromDataURL(this.signatureUrl);
        }
    }

    handleClearClicked() {
        this.signaturePad.clear();
    }
}