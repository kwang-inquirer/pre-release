/* eslint-disable no-alert */
/* eslint-disable no-console */
/* eslint-disable no-unused-vars */
import { LightningElement, api, track } from 'lwc';
import confirmPasswordReset from '@salesforce/apex/Auth0Controller.confirmPasswordReset'


export default class ChangePasswordAuth0 extends LightningElement {
    @track confirmationPage;
    @api contactId;

    connectedCallback() {
        this.confirmationPage = false;
    }

    handleSubmit(){
        confirmPasswordReset({contactId: this.contactId})
            .then(result => {
                if(result === 'SUCCESS'){
                    this.confirmationPage = true;
                }
            })
            .catch(error => {
                window.alert('An error has occured. Please contact an administrator');
            });
    }

}