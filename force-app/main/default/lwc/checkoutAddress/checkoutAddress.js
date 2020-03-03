import { LightningElement, api, track } from 'lwc';

export default class CheckoutAddress extends LightningElement {
    @track errors;
    @track _address;
    @track _country = 'US';

    @api label;
    @api disabled = false;
    @api required = false;
    @api showName = false;

    @api validate() { return this.validateAddress() }

    @api
    get address() { return this._address; }
    set address(address) { this._address = { ...address }; }

    get getProvinceOptions() { return this.stateOptions[this._country]; }
    get getCountryOptions() { return this.countryOptions; }

    connectedCallback() { this.setCountryName(); }

    handleAddressChange(event) {
        let address = { ...this._address };
        address.street = event.detail.street;
        address.city = event.detail.city;
        address.state = event.detail.province;
        address.postalCode = event.detail.postalCode;
        address.country = event.detail.country;
        this._address = address;
        this._country = event.detail.country;

        const selectedEvent = new CustomEvent('addresschange', { detail: this.address });
        this.dispatchEvent(selectedEvent);
    }

    handleNameChange(event) {
        this.address[event.target.name] = event.target.value;
        
        const selectedEvent = new CustomEvent('addresschange', { detail: this.address });
        this.dispatchEvent(selectedEvent);
    }

    validateAddress() {
        let _this = this;
        return new Promise((resolve, reject) => {
            if (_this.address.postalCode && _this.address.postalCode.length < 5) {
                reject(['Invalid postal code']);
            }
            if (!_this.template.querySelector('lightning-input-address').reportValidity()) {
                reject();
            }
            _this.template.querySelectorAll('lightning-input').forEach(input => {
                if (!input.reportValidity()) {
                    reject();
                }
            });
            resolve();
        });
    }

    setCountryName() {
        if (this.address.country !== 'US') {
            this.address.country = 'US';
        }
    }

    countryOptions = [
        { label: 'United States', value: 'US' }
    ];

    stateOptions = {
        US: [
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
        ]
    };
}