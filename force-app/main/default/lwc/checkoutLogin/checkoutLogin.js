import { LightningElement, track, api } from 'lwc';

export default class AuthLogin extends LightningElement {
    @track loading = false;
    @track _credentials;

    @api
    get credentials() { return this._credentials; }
    set credentials(credentials) { this._credentials = {...credentials}; }

    get showPasswordInput() { return this._credentials.email; }

    handleChange(event) {
        this._credentials[event.target.name] = event.target.value;
    }

    handleLoginClicked() {
        this.login();
    }

    validateCredentials() {
        return new Promise((resolve, reject) => {
            this.template.querySelectorAll('lightning-input').forEach(input => {
                if (!input.reportValidity()) {
                    reject();
                }
            });
            resolve(true);
        });
    }

    login() {
        this.loading = true;
        this.validateCredentials()
            .then(() => this.onValidateSuccess())
            .catch(() => this.onError())
    }

    onValidateSuccess() {
        this.loading = false;
        const selectedEvent = new CustomEvent('next', { detail: this._credentials });
        this.dispatchEvent(selectedEvent);
    }

    onError() {
        this.loading = false;
        this.errors = ['Failed to authenticate'];
    }

    connectedCallback() {
        if (this._credentials.email) {
            this.onValidateSuccess();
        }
    }
}