import { LightningElement, track } from 'lwc';

import updatePassword from '@salesforce/apex/Auth0Controller.updatePassword';

const defaultCredentials = { newPassword: null, confirmNewPassword: null}; 

export default class ChangeProfile extends LightningElement {
    @track errorMessage;
    @track successMessage;
    @track credentials = {...defaultCredentials};

    handleChange(event) { this.credentials[event.detail.name] = event.detail.value; }
    handleUpdate() { this.updateCredentails() }
    handleCancel() { this.cancel() }

    updateCredentails() {
        this.errorMessage = null;
        this.successMessage = null;
        if (this.credentials.newPassword !== this.credentials.confirmNewPassword) {
            this.errorMessage = 'New password does not match';
            return;
        }
        updatePassword({ password: this.credentials.newPassword })
            .then(() => {
                this.successMessage = 'Password has been updated'
            })
            .catch(message => {
                this.errorMessage = message
            });
    }

    cancel() {
        this.credentials = {...defaultCredentials}
    }
}