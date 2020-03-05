/* eslint-disable no-unused-vars */
/* eslint-disable no-irregular-whitespace */
/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
import { LightningElement, api, track} from 'lwc';
import createNewDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.createNewDeliveryAddress'
import hasValidDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.hasValidDeliveryAddress'
import deleteDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.deleteDeliveryAddress'
import updateBillingAddress from '@salesforce/apex/changeAddressController.updateBillingAddress'
import updateDeliveryAddress from '@salesforce/apex/changeAddressController.updateDeliveryAddress'
import validateDeliverySchedules from '@salesforce/apex/changeAddressController.validateDeliverySchedules'

export default class ChangeAddress extends LightningElement {
    @api recordId;
    @api subscriptionId;
    @api
    get address() { return this._address; }
    set address(address) { this._address = { ...address }; }
    @api
    get deliveryAddress() { return this._deliveryAddress; }
    set deliveryAddress(deliveryAddress) { this._deliveryAddress = { ...deliveryAddress }; }
    @track effectiveDate;
    @track isLoading;
    @track options = [] ;
    @track radioValue;
    @track defaultCountry;
    @track defaultState;
    @track errors = [];
    @track updateDeliveryAddress;
    @track sameAddress;
    @track confirmationPage;
    @track submitDisabled;
    @track successMessage;

    connectedCallback(){
        this.submitDisabled = false;
        this.subscriptionId = this.recordId;
        validateDeliverySchedules({ subId: this.subscriptionId})
        .then(() => {
            
        })
        .catch(() => {
            this.errors = ['A split delivery exists for this subcription. Please contact customer service.'];
            this.submitDisabled = true;
            //this.existingSplitDelivery = true;
        });
        this.setupRadioGroup();
        this.updateDeliveryAddress = false;
        this.sameAddress = true;
        this.setCountryName();
    }
    handleSubmit(){
        this.isLoading = true;
        let updateBillingAddressPromise = new Promise((resolve, reject) => {
            updateBillingAddress({ subId: this.subscriptionId, address : this._address})
            .then(() => {
                resolve();
            })
            .catch(errors => { reject(errors || ['There is not a current route available for this address.']) }) 
        });
        
        updateBillingAddressPromise.then(() => {
            var finalAddress;
            if(this.sameAddress){
                finalAddress = this._address;
            }
            else{
                finalAddress = this._deliveryAddress;
            }
            if(this.updateDeliveryAddress)
            {
                let createAddressPromise = new Promise((resolve, reject) => {
                 createNewDeliveryAddress({ subId: this.subscriptionId, address : finalAddress})
                .then(createdId => {
                    const validateParams = { newAddressId: createdId };
                       this.retry(hasValidDeliveryAddress, validateParams)
                           .then(valid => {
                               if (!valid) {
                                  reject('There is not a current route available for this address.');
                               } else {
                                    resolve(createdId);
                                    }
                                })
                                .catch(() => {
                                    deleteDeliveryAddress({newAddressId: createdId})
                                    .then(() => {
                                        reject('There is not a current route available for this address.');
                                    })
                                        
                                })
                            })
                    .catch(errors => { reject(errors || ['There is not a current route available for this address.']) }) 
                });
            
                createAddressPromise.then((createdId) => {
                    updateDeliveryAddress({ subId: this.subscriptionId, deliveryAddressId: createdId, effectiveDate : this.effectiveDate})
                    .then(updResult => {
                        this.confirmationPage = true;
                        this.isLoading = false;

                        this.successMessage = 'The address was successfully changed with effective date: ' + updResult;
                    })
                    .catch(() =>
                    {
                        this.errors[0] = ['There is not a current route available for this address.'];
                        this.isLoading = false;
                    })
                })
                .catch((error) => {
                    this.errors[0] = ['There is not a current route available for this address.'];
                    this.isLoading = false;
                })
            }
            else{
                this.confirmationPage = true;
                this.isLoading = false;
            }   
        
       
        })
        .catch((promiseResult) => {
            this.errors = [promiseResult];
            this.isLoading = false;
        })
        
    }
    setupRadioGroup(){
        var selectOption = {
            label: 'Billing Address Only',
            value: 'BAO'
        };
        var selectOption2 = {
            label: 'Delivery and Billing Address',
            value: 'DABA'
        };
        this.options.push(selectOption);
        this.options.push(selectOption2);   
        this.radioValue = 'BAO';
        this.updateDeliveryAddress = false;
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
    handleDeliveryAddressChange(event) {
        let address = { ...this._address };
        address.street = event.detail.street;
        address.city = event.detail.city;
        address.state = event.detail.province;
        address.postalCode = event.detail.postalCode;
        address.country = event.detail.country;
        this._deliveryAddress = address;
    }
    handleFormInputChange(event){
        this.effectiveDate = event.target.value;
    }
    changeSelection(event){
        this.radioValue = event.target.value;
        if(event.target.value === "DABA"){
            this.updateDeliveryAddress = true;
        }
        else{
            this.updateDeliveryAddress = false;
        }
    }
    
    sameAddressChange(event){
        this.sameAddress = event.target.checked;
    }
    get hasErrors() { return this.errors && this.errors.length > 0; }
    setCountryName() {
        this.defaultCountry = 'US';
        this.defaultState = 'PA';
    }
    countryOptions = [
        { label: 'United States', value: 'US' }
    ];
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