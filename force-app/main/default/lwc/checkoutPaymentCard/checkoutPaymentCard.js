import { LightningElement, api, track } from 'lwc';

const CurrentYear = new Date().getFullYear();

const PaymentOptions = [
    { label: '--None--', value: '' },
    { label: 'Visa', value: 'visa' },
    { label: 'Mastercard', value: 'mastercard' },
    { label: 'Discover', value: 'discover' },
    { label: 'American Express', value: 'american express' },
];

const MonthOptions = [
    { label: '--None--', value: '' },
    { label: 'January', value: '01' },
    { label: 'February', value: '02' },
    { label: 'March', value: '03' },
    { label: 'April', value: '04' },
    { label: 'May', value: '05' },
    { label: 'June', value: '06' },
    { label: 'July', value: '07' },
    { label: 'August', value: '08' },
    { label: 'September', value: '09' },
    { label: 'October', value: '10' },
    { label: 'November', value: '11' },
    { label: 'December', value: '12' }
];

const YearOptions = [
    { label: '--None--', value: '' },
    { label: (CurrentYear).toString(), value: (CurrentYear).toString() },
    { label: (CurrentYear + 1).toString(), value: (CurrentYear + 1).toString() },
    { label: (CurrentYear + 2).toString(), value: (CurrentYear + 2).toString() },
    { label: (CurrentYear + 3).toString(), value: (CurrentYear + 3).toString() },
    { label: (CurrentYear + 4).toString(), value: (CurrentYear + 4).toString() },
    { label: (CurrentYear + 5).toString(), value: (CurrentYear + 5).toString() }
];

export default class PaymentInformation extends LightningElement {
    @track _payment;
    @track typeOptions = PaymentOptions;
    @track monthOptions = MonthOptions;
    @track yearOptions = YearOptions;

    @api subscription;

    @api
    get payment() { return this._payment }
    set payment(payment) { this._payment = { ...payment } }

    @api validate() { return this.validatePayment() }

    handleChange(event) { this.onChange(event) }
    handleNumericTextChange(event) { this.onNumericTextChange(event) }
    handleCardNumberChange(event) { this.onCardNumberChange(event) }

    onChange(event) {
        this.payment[event.target.name] = event.target.value;
        this.paymentChanged();
    }

    onNumericTextChange(event) {
        this.payment[event.target.name] = event.target.value;
        this.reportNanValidity(event, event.target.value);
        this.paymentChanged();
    }
    
    onCardNumberChange(event) {
        if (event.target.value) {
            let strippedCardNumber = event.target.value.split("-").join("");
            this.payment.cardNumber = strippedCardNumber.match(new RegExp('.{1,4}', 'g')).join("-");
            this.payment.type = this.getTypeFromCardNumber(event.target.value);
            this.reportNanValidity(event, strippedCardNumber);
            this.paymentChanged();
        }
    }

    validatePayment() {
        return new Promise((resolve, reject) => {
            let hasErrors = false;
            this.template.querySelectorAll('lightning-input').forEach(input => {
                if (!input.reportValidity()) {
                    hasErrors = true;
                }
            });
            this.template.querySelectorAll('lightning-combobox').forEach(input => {
                if (!input.reportValidity()) {
                    hasErrors = true;
                }
            });
            if (hasErrors) {
                reject();
                return;
            } 
            resolve();
        });
    }

    getTypeFromCardNumber(cardNumber) {
        if (cardNumber.startsWith('3')) {
            return 'american express';
        } else if (cardNumber.startsWith('4')) {
            return 'visa';
        } else if (cardNumber.startsWith('5')) {
            return 'mastercard';
        } else if (cardNumber.startsWith('6')) {
            return 'discover';
        }
        return '';
    }

    reportNanValidity(event, value) {
        event.target.setCustomValidity('');
        if (isNaN(value)) {
            event.target.setCustomValidity('Must contain numeric characters');
        }
        event.target.reportValidity();
    }

    paymentChanged() {
        const selectedEvent = new CustomEvent('paymentchanged', { detail: this.payment });
        this.dispatchEvent(selectedEvent);
    }
}