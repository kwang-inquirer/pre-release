/* eslint-disable no-alert */
/* eslint-disable no-else-return */
/* eslint-disable consistent-return */
/* eslint-disable vars-on-top */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable no-console */
import { LightningElement, api, track} from 'lwc';

import getDeliveryAddresses from '@salesforce/apex/DeliveryAddressDataAccessor.getDeliveryAddresses';
import createNewDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.createNewDeliveryAddress';
import hasValidDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.hasValidDeliveryAddress';
import deleteDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.deleteDeliveryAddress';
import createDeliverySchedule from '@salesforce/apex/ShoreMoveController.createDeliverySchedule';

export default class ShoreMove extends LightningElement 
{
    @api recordId;
    @api startDate;
    @api returnDate;
    @api formattedDate;
    @api
    get address() { return this._address; }
    set address(address) { this._address = { ...address }; }
    @track addresses = []; 
    @track addressList = []; //radio group options
    @track value; //default value of radio group
    @track errors;
    @track subscriptionId; //This is the subscription id to set from a flow, record page, etc.
    @track defaultCountry;
    @track defaultState;
    @track newAddressId;
    @track isLoading;
    @track confirmationPage;
    @track successMessage;
    
    
    connectedCallback() {
        this.setCountryName();
        this.subscriptionId = this.recordId;
        this.isButtonDisabled = false;
        this.confirmationPage = false;
        getDeliveryAddresses({ subId: this.subscriptionId})
            .then(result => {
                this.addresses = result;
                for(var i = 0; i < this.addresses.length; i++){
                    if(i===0){
                        this.value = this.addresses[i].Id;
                    }
                    var newOption = {
                        label: this.addresses[i].Address_House__c + ' ' + this.addresses[i].Address_Street__c + ' - ' + this.addresses[i].Address_City__c,
                        value: this.addresses[i].Id
                    };
                    this.addressList.push(newOption);
                }
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleFormInputChange(event){
        if( event.target.name === 'startDate'){
            this.startDate = event.target.value;
        }
        else if( event.target.name === 'returnDate'){
            this.returnDate = event.target.value;
        }
    }

    get hasErrors() { return this.errors && this.errors.length > 0; }
 
    handleSubmit() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
    if (allValid) {
        const saveParams = ({ subId: this.subscriptionId, address: this._address });
        return new Promise((resolve) => {
         createNewDeliveryAddress(saveParams)
                .then(result => {
                 const validateParams = { newAddressId: result };
                 this.isLoading = true;
                    this.retry(hasValidDeliveryAddress, validateParams)
                        .then(valid => {
                            if (!valid) {
                                
                                    this.errors = ['There is not a current route available for this address.'];
                                    this.isLoading = false;
                               
                            } else { 
                                createDeliverySchedule({oldAddressId: this.value, newAddressId: valid, subId : this.subscriptionId, startDate: this.startDate, endDate: this.returnDate})
                                .then(dsResult => {
                                    this.isLoading = false;
                                    this.confirmationPage = true;
                                    this.successMessage = 'The delivery will begin ' + dsResult;
                                    if(this.returnDate != null) {
                                        var myDT = new Date(this.returnDate + " 12:00:00 EST");
                                        this.formattedDate = myDT.getMonth()+1 + '/' + myDT.getDate() + '/' + myDT.getFullYear();
                                        this.successMessage += ' and end ' + this.formattedDate;
                                    }
                                })
                                resolve();
                            }
                        })
                        
                        .catch(() => {
                            deleteDeliveryAddress({newAddressId: result})
                            .then(() => {
                                this.errors = ['There is not a current route available for this address.'];
                                this.isLoading = false;
                            })
                        })
                })
                .catch(() => {
                 this.errors = ['There is not a current route available for this address.']; })
        });
    } else {
        alert('Please update the invalid form entries and try again.');
       
    }
       
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

    provinceOptions = [
        { "label": "Alabama", "value": "AL" },
        { "label": "Alaska", "value": "AK" },
        { "label": "Arizona", "value": "AZ" },
        { "label": "Arkansas", "value": "AR" },
        { "label": "California", "value": "CA" },
        { "label": "Colorado", "value": "CO" },
        { "label": "Connecticut", "value": "CT" },
        { "label": "Delaware", "value": "DE" },
        { "label": "Florida", "value": "FL" },
        { "label": "Georgia", "value": "GA" },
        { "label": "Hawaii", "value": "HI" },
        { "label": "Idaho", "value": "ID" },
        { "label": "Illinois", "value": "IL" },
        { "label": "Indiana", "value": "IN" },
        { "label": "Iowa", "value": "IA" },
        { "label": "Kansas", "value": "KS" },
        { "label": "Kentucky", "value": "KY" },
        { "label": "Louisiana", "value": "LA" },
        { "label": "Maine", "value": "ME" },
        { "label": "Maryland", "value": "MD" },
        { "label": "Massachusetts", "value": "MA" },
        { "label": "Michigan", "value": "MI" },
        { "label": "Minnesota", "value": "MN" },
        { "label": "Mississippi", "value": "MS" },
        { "label": "Missouri", "value": "MO" },
        { "label": "Montana", "value": "MT" },
        { "label": "Nebraska", "value": "NE" },
        { "label": "Nevada", "value": "NV" },
        { "label": "New Hampshire", "value": "NH" },
        { "label": "New Jersey", "value": "NJ" },
        { "label": "New Mexico", "value": "NM" },
        { "label": "New York", "value": "NY" },
        { "label": "North Carolina", "value": "NC" },
        { "label": "North Dakota", "value": "ND" },
        { "label": "Ohio", "value": "OH" },
        { "label": "Oklahoma", "value": "OK" },
        { "label": "Oregon", "value": "OR" },
        { "label": "Pennsylvania", "value": "PA" },
        { "label": "Rhode Island", "value": "RI" },
        { "label": "South Carolina", "value": "SC" },
        { "label": "South Dakota", "value": "SD" },
        { "label": "Tennessee", "value": "TN" },
        { "label": "Texas", "value": "TX" },
        { "label": "Utah", "value": "UT" },
        { "label": "Vermont", "value": "VT" },
        { "label": "Virginia", "value": "VA" },
        { "label": "Washington", "value": "WA" },
        { "label": "West Virginia", "value": "WV" },
        { "label": "Wisconsin", "value": "WI" },
        { "label": "Wyoming", "value": "WY" }
    ];

    countryOptions = [
        { label: 'United States', value: 'US' }
    ];
    setCountryName() {
        this.defaultCountry = 'US';
        this.defaultState = 'PA';
    }

    handleAddressChange(event) {
        let address = { ...this._address };
        address.street = event.detail.street;
        address.city = event.detail.city;
        address.state = event.detail.province;
        address.postalCode = event.detail.postalCode;
        address.country = event.detail.country;
        this._address = address;

    }

    get options() {
        return this.addressList;
    }
    changeSelection(event){
        this.value = event.target.value;
    }
}