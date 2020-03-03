import { LightningElement, api, track } from 'lwc';

import getSubscriptionById from '@salesforce/apex/SubscriptionController.getSubscriptionById';

const StepTypes = {
    BILLING: 'billing',
    PAYMENT: 'payment',
    COMPLETE: 'complete',
}

const Steps = [
    { label: 'Billing', value: StepTypes.BILLING },
    { label: 'Payment', value: StepTypes.PAYMENT },
    { label: 'Complete', value: StepTypes.COMPLETE },
]

const DefaultCheckout = {
    billingAddress: { firstName: '', lastName: '', street: '', city: '', state: '', postalCode: '', country: 'US' },
    payment: { name: 'Rob Hibinger', cardNumber: /*'4000-0000-0000-0002'*/'4111-1111-1111-1111', type: 'visa', month: '01', year: '2020', cvc: '123' }
}

export default class CheckoutEzPayProcess extends LightningElement {
    @track offer;
    @track subscription;
    @track steps = Steps;
    @track currentStep = StepTypes.INIT;
    @track loading = false;
    @track errors = null;
    @track hasOnlyDigitalProducts = false;
    @track checkout = { ...DefaultCheckout };

    @api subscriptionId;

    get hasErrors() { return this.errors && this.errors.length > 0 }
    get billingActive() { return this.currentStep === StepTypes.BILLING && this.subscription }
    get paymentActive() { return this.currentStep === StepTypes.PAYMENT && this.subscription }
    get completeActive() { return this.currentStep === StepTypes.COMPLETE }
    get showCheckout() { return this.subscription; }

    handleNext(event) { this.next(event.detail); }
    handlePrevious(event) { this.previous(event.detail); }

    next(detail) {
        switch (this.currentStep) {
            case StepTypes.BILLING:
                this.checkout.billingAddress = detail;
                this.currentStep = StepTypes.PAYMENT;
                break;
            case StepTypes.PAYMENT:
                this.checkout.payment = detail;
                this.currentStep = StepTypes.COMPLETE;
                const selectedEvent = new CustomEvent('success');
                this.dispatchEvent(selectedEvent);
                break;
            default:
                break;
        }
    }

    previous(detail) {
        switch (this.currentStep) {
            case StepTypes.PAYMENT:
                this.checkout.payment = detail;
                this.currentStep = StepTypes.BILLING;
                break;
            default:
                break;
        }
    }

    getSubscriptionById(subId) {
        return new Promise((resolve, reject) => {
            getSubscriptionById({ subId: subId })
                .then(subscription => {
                    resolve(subscription);
                })
                .catch(() => {
                    reject(['Failed to retrieve subscription']);
                })
        });
    }

    init() {
        console.log(this.subscriptionId);
        if (!this.subscriptionId) {
            this.errors = ['A subscription id is required'];
            return;
        }
        this.initSubscription();
    }

    loadState(subscription) {
        this.subscription = subscription;
        if (this.subscription) {
            this.setBillingState();
        }
    }

    setBillingState() {
        if (this.subscription.Contact__r) {
            this.checkout.billingAddress.firstName = this.subscription.Contact__r.FirstName;
            this.checkout.billingAddress.lastName = this.subscription.Contact__r.LastName;
        }
        if (this.subscription.subscription_Account__r) {
            this.checkout.billingAddress.street = this.subscription.subscription_Account__r.BillingStreet;
            this.checkout.billingAddress.city = this.subscription.subscription_Account__r.BillingCity;
            this.checkout.billingAddress.state = this.subscription.subscription_Account__r.BillingState;
            this.checkout.billingAddress.postalCode = this.subscription.subscription_Account__r.BillingPostalCode;
            this.checkout.billingAddress.country = this.subscription.subscription_Account__r.BillingCountry;
        }
    }

    initSubscription() {
        this.loading = true;
        this.currentStep = StepTypes.BILLING;
        this.getSubscriptionById(this.subscriptionId)
            .then(subscription => {
                this.loadState(subscription);
                this.loading = false;
            })
            .catch(errors => {
                this.errors = errors;
                this.loading = false;
            });
    }

    connectedCallback() {
        this.init();
    }
}