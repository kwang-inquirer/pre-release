/* eslint-disable no-irregular-whitespace */
/* eslint-disable no-unused-vars */
/* eslint-disable no-console */
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable vars-on-top */
import { LightningElement, api, track } from 'lwc';
import getDeliverySchedules from '@salesforce/apex/SplitDeliveryController.getDeliverySchedules'
import rebuildDeliverySchedules from '@salesforce/apex/SplitDeliveryController.rebuildDeliverySchedules'
import createNewDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.createNewDeliveryAddress'
import deleteDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.deleteDeliveryAddress'
import hasValidDeliveryAddress from '@salesforce/apex/DeliveryAddressDataAccessor.hasValidDeliveryAddress';

export default class SplitDelivery extends LightningElement {
    @api recordId;
    @api subscriptionId;
    @api startDate;
    @api returnDate;
    @api
    get weekendAddress() { return this._weekendAddress; }
    set weekendAddress(weekendAddress) { this._weekendAddress = { ...weekendAddress }; }
    @api
    get weekdayAddress() { return this._weekdayAddress; }
    set weekdayAddress(weekdayAddress) { this._weekdayAddress = { ...weekdayAddress }; }
    @track schedules = []; 
    @track scheduleList = [];
    @track error;
    @track errors = [];
    @track value; //default value of radio group
    @track weekendSelection;
    @track weekdaySelection;
    @track newWeekendSelection;
    @track newWeekdaySelection;
    @track weekendAddress;
    @track weekdayAddress;
    @track defaultCountry;
    @track defaultState;
    @track newAddressId;
    @track isLoading;
    @track isButtonDisabled;
    @track confirmationPage;
    @track showCreateWeekend;
    @track showCreateWeekday;
    @track finalWeekdayAddress;
    @track finalWeekendAddress;
    @track confirmationPage;
    

    connectedCallback() {
        this.confirmationPage = false;
        this.setCountryName();
        this.subscriptionId = this.recordId;
        getDeliverySchedules({ subId: this.subscriptionId})
            .then(result => {
                this.schedules = result;
                for(var i = 0; i < this.schedules.length; i++){
                    
                    if(i===0){
                        this.weekdaySelection = this.schedules[i].Delivery_Address__c;
                        this.weekendSelection = this.schedules[i].Delivery_Address__c;
                    }
                    var newOption = {
                        label: this.schedules[i].Delivery_Address__r.Address_House__c + ' ' + this.schedules[i].Delivery_Address__r.Address_Street__c + ' - ' + this.schedules[i].Delivery_Address__r.Address_City__c + ' (' + this.schedules[i].Frequency_Code__c + ')',
                        value: this.schedules[i].Delivery_Address__c,
                        frequency: this.schedules[i].Frequency_Code__c
                    };
                    this.scheduleList.push(newOption);
                }
                var createOption = {
                    label: 'Select if none of the addresses above are the the weekday delivery address',
                    value: 'Create',
                    frequency: ''
                };
                this.scheduleList.push(createOption);
                this.scheduleList = this.scheduleList.filter((set => f => !set.has(f.value) && set.add(f.value))(new Set));
            })
            .catch(error => {
                this.errors = [' A split delivery already exists for this subcription'];
                this.existingSplitDelivery = true;
            });
    }
    setCountryName() {
        this.defaultCountry = 'US';
        this.defaultState = 'PA';
    }

    countryOptions = [
        { label: 'United States', value: 'US' }
    ];
    handleWeekendAddressChange(event) {
        let weekendAddress = { ...this._weekendAddress };
        weekendAddress.street = event.detail.street;
        weekendAddress.city = event.detail.city;
        weekendAddress.state = event.detail.province;
        weekendAddress.postalCode = event.detail.postalCode;
        weekendAddress.country = event.detail.country;
        this._weekendAddress = weekendAddress;

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
    
    handleSubmit(){
        this.confirmationPage = false;
        this.isLoading = true;

        let setWeekDayPromise = new Promise((resolve, reject) => {
            if(this.showCreateWeekday){
                 createNewDeliveryAddress({ subId: this.subscriptionId, address : this._weekdayAddress})
                .then(createdId => {
                    const validateParams = { newAddressId: createdId };
                       this.retry(hasValidDeliveryAddress, validateParams)
                           .then(valid => {
                               if (!valid) {
                                  reject('There is not a current route available for this address.');
                               } else {
                                    this.finalWeekdayAddress = valid;
                                    resolve('');
                                    }
                                })
                                .catch(() => {
                                    reject('There is not a current route available for this address.');
                                })
                            })
                            .catch(errors => { reject(errors || ['There is not a current route available for this address.']) }) 
                        }
            else{
                this.finalWeekdayAddress = this.weekdaySelection;
                resolve();
            }
        });

        //Promise 1 - Set Weekday
        setWeekDayPromise.then((message) => {
            let setWeekEndPromise = new Promise((resolve, reject) => {
                if(this.showCreateWeekend){
                     createNewDeliveryAddress({ subId: this.subscriptionId, address : this._weekendAddress})
                    .then(createdId => {
                        const validateParams = { newAddressId: createdId };
                           this.retry(hasValidDeliveryAddress, validateParams)
                               .then(valid => {
                                   if (!valid) {
                                      reject('There is not a current route available for this address.');
                                   } else {
                                        this.finalWeekendAddress = valid;
                                        resolve();
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
                            }
                else{
                    this.finalWeekendAddress = this.weekendSelection;
                    resolve();
                }
            });
            //Promise 2 - Set Weekend
            setWeekEndPromise.then((result) => {
                //Promise 3 - Rebuild Delivery Schedules
                let rebuildPromise = new Promise((resolve, reject) => {
                    rebuildDeliverySchedules({ subId: this.subscriptionId, startDate: this.startDate, endDate: this.returnDate, weekendSelection : this.finalWeekendAddress, weekdaySelection : this.finalWeekdayAddress})
                                .then(() => {
                                   resolve();
                                })
                                .catch(error => {
                                    console.log(error);
                                    reject('This subscription requires a delivery schedule with both weekday and weekend deliveries.');
                                });

                });

                rebuildPromise.then((finalResult) => {
                    this.confirmationPage = true;
                    this.isLoading = false;
                    this.errors = null;

                })
                .catch((finalResult) => {
                    this.errors = [finalResult];
                    this.isLoading = false;

                    
                })
            })
            .catch((result) =>
            {
                this.errors = [result];  
                this.isLoading = false;

            })
        })
        .catch((message) =>
        {
            this.errors[0] = [message];
            this.isLoading = false;

            
        })

        
    }
    handleWeekdayAddressChange(event) {
        let weekdayAddress = { ...this._weekdayAddress };
        weekdayAddress.street = event.detail.street;
        weekdayAddress.city = event.detail.city;
        weekdayAddress.state = event.detail.province;
        weekdayAddress.postalCode = event.detail.postalCode;
        weekdayAddress.country = event.detail.country;
        this._weekdayAddress = weekdayAddress;

    }
    get options() {
        return this.scheduleList;
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
    changeWeekdaySelection(event){
        this.weekdaySelection = event.target.value; 
        if(event.target.value === 'Create')
            this.showCreateWeekday = true;
        else
            this.showCreateWeekday = false;
    }
    changeWeekendSelection(event){
        this.weekendSelection = event.target.value;
        if(event.target.value === 'Create')
            this.showCreateWeekend = true;
        else
        this.showCreateWeekend = false;
    }
}