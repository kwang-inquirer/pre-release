import { LightningElement, api, track } from 'lwc';

import callPiano from '@salesforce/apex/CheckoutController.callPiano';
import getOfferById from '@salesforce/apex/CheckoutController.getOfferById';
import getSubscriptionById from '@salesforce/apex/CheckoutController.getSubscriptionById';
import getNewSubscription from '@salesforce/apex/CheckoutController.getNewSubscription';

const StepTypes = {
    INIT: 'init',
    LOGIN: 'login',
    DELIVERY: 'delivery',
    BILLING: 'billing',
    CONFIRMATION: 'confirmation'
}

export default class CheckoutProcess extends LightningElement {
    @track steps;
    @track offer;
    @track errors;
    @track credentials;
    @track subscription;
    @track currentStep = StepTypes.INIT;
    @track loading = false;
    @track hasOnlyDigitalProducts = false;
    @track deliveryAddress = { street: '', city: '', state: '', postalCode: '', country: 'US' };
    @track billingAddress = { firstName: '', lastName: '', street: '', city: '', state: '', postalCode: '', country: 'US' };

    @api email;
    @api source;
    @api pianoId;
    @api offerId;
    @api sessionId;
    @api subscriptionId;
	@api sourceCampaign;
    @api isFlow = false;
    @api editPayment = false;
    @api enableAutoPay = false;
    @api processPayment = false;
    @api waiveActivationFee = false;
    @api showAgreementBeforeSubmit = false;

    get hasErrors() { return this.errors && this.errors.length > 0 }
    get loginActive() { return this.currentStep === StepTypes.LOGIN }
    get deliveryActive() { return this.currentStep === StepTypes.DELIVERY && this.subscription }
    get billingActive() { return this.currentStep === StepTypes.BILLING && this.subscription }
    get confirmationActive() { return this.currentStep === StepTypes.CONFIRMATION && this.offer }
    get offerHasLineItems() { return this.offer && this.offer.Offer_Products__r }
    get showCheckout() { return (this.currentStep === StepTypes.LOGIN && this.offer) || (this.offer && this.subscription) }
    get showOfferDetails() { return this.currentStep !== StepTypes.LOGIN && this.offer }
    get showBillingPrevious() { return !this.subscriptionId || (this.offerId && !this.hasOnlyDigitalProducts) }
    get isNewSubscription() { return this.offerId }
    get showSubscriptionStartedMessage() { return this.offerId }
    get showPaymentSubmittedMessage() { return this.subscriptionId && this.processPayment }
    get showSubscriptionStartDate() { return this.offerId }
    get showEzPayMessage() { return !this.processPayment }

    connectedCallback() { this.init() }
    handleNext(event) { this.next(event.detail) }
    handlePrevious(event) { this.previous(event.detail) }

    next(detail) {
        switch (this.currentStep) {
            case StepTypes.LOGIN:
                this.credentials = detail;
                this.loginSuccess();
                break;
            case StepTypes.DELIVERY:
                this.deliveryAddress = detail;
                this.currentStep = StepTypes.BILLING;
                break;
            case StepTypes.BILLING:
                this.billingAddress = detail.address;
                this.payment = detail.payment;
                this.handlePiano();
                this.getSubscriptionById(this.subscription.Id)
                    .then(subscription => {
                        this.subscription = subscription;
                        this.currentStep = StepTypes.CONFIRMATION;
                    })
                break;
            default:
                break;
        }
    }

    previous(detail) {
        switch (this.currentStep) {
            case StepTypes.BILLING:
                this.billingAddress = detail;
                this.currentStep = StepTypes.DELIVERY;
                break;
            case StepTypes.PAYMENT:
                this.payment = detail;
                this.currentStep = StepTypes.BILLING;
                break;
            default:
                break;
        }
    }

    loginSuccess() {
        this.errors = null;
        this.loading = true;
        this.getNewSubscription(this.offerId, this.credentials.email, this.source, this.credentials.password, this.waiveActivationFee, this.sourceCampaign)
            .then(subscription => this.onGetDefaultNewSubscriptionSuccess(subscription))
            .catch(errors => this.onGetDefaultNewSubscriptionError(errors));
    }

    onGetDefaultNewSubscriptionSuccess(subscription) {
        this.processSubscription(subscription);
        if (this.offer.Free_Trial__c) {
            this.currentStep = StepTypes.CONFIRMATION;
        } else if (this.hasOnlyDigitalProducts) {
            this.currentStep = StepTypes.BILLING;
        } else {
            this.currentStep = StepTypes.DELIVERY;
        }
        this.loading = false;
    }

    onGetDefaultNewSubscriptionError(errors) {
        this.errors = errors;
        this.loading = false;
    }

    processOffer(offer) {
        this.offer = offer;
        this.hasOnlyDigitalProducts = true;
        if (this.offer.Offer_Products__r) {
            this.hasOnlyDigitalProducts = this.offer.Offer_Products__r.filter(prod => !prod.Is_Digital__c).length === 0;
        }
    }

    processSubscription(subscription) {
        this.subscription = subscription;
        if (this.subscription) {
            this.setBillingName(this.subscription.Contact__r);
            this.setBillingAddress(this.subscription.subscription_Account__r);
            if (this.subscription.Delivery_Schedules__r && this.subscription.Delivery_Schedules__r.length > 0) {
                this.setDeliveryAddress(this.subscription.Delivery_Schedules__r[0].Delivery_Address__r);
            }
        }
    }

    setBillingName(contact) {
        if (contact) {
            if (contact.FirstName !== 'New' && contact.LastName !== 'Subscriber') {
                this.billingAddress.firstName = contact.FirstName;
                this.billingAddress.lastName = contact.LastName;
            }
        }
    }

    setDeliveryAddress(deliveryAddress) {
        if (deliveryAddress) {
            this.deliveryAddress.street = deliveryAddress.Address_Full_Street__c;
            this.deliveryAddress.city = deliveryAddress.Address_City__c;
            this.deliveryAddress.state = deliveryAddress.Address_State__c;
            this.deliveryAddress.postalCode = deliveryAddress.Zip__c;
            this.deliveryAddress.country = 'US';
        }
    }

    setBillingAddress(billingAddress) {
        if (billingAddress) {
            this.billingAddress.street = billingAddress.BillingStreet;
            this.billingAddress.city = billingAddress.BillingCity;
            this.billingAddress.state = billingAddress.BillingState;
            this.billingAddress.postalCode = billingAddress.BillingPostalCode;
            this.billingAddress.country = (billingAddress.BillingCountry !== 'USA') ? billingAddress.BillingCountry : 'US';
        }
    }

    onGetOfferByIdSuccess(offer) {
        this.processOffer(offer);
        this.initSteps();
        this.loading = false;
    }

    onGetSubscriptionById(subscription) {
        this.processSubscription(subscription);
        return this.getOfferById(subscription.subscription_Offer__c)
    }

    onError(errors) {
        this.errors = errors;
        this.loading = false;
    }

    handlePiano() {
        if (this.pianoId) {
            callPiano({ pianoId: this.pianoId}).then(() => { }).catch(() => { });
        }
    }

    //
    //  Initialization
    //

    init() {
        this.initSteps();
        this.credentials = { email: this.email, password: '', sessionId: '' };
        if (this.subscriptionId) {
            this.initSubscription();
        }
        else if (this.offerId) {
            this.initOffer();
        } else {
            this.errors = ['A subscription or offer is required during checkout'];
        }
    }

    initSubscription() {
        this.loading = true;
        this.currentStep = StepTypes.BILLING;
        this.getSubscriptionById(this.subscriptionId)
            .then(subscription => this.onGetSubscriptionById(subscription))
            .then(offer => this.onGetOfferByIdSuccess(offer))
            .catch(errors => this.onError(errors));
    }

    initOffer() {
        this.loading = true;
        this.currentStep = StepTypes.LOGIN;
        this.getOfferById(this.offerId)
            .then(offer => this.onGetOfferByIdSuccess(offer))
            .catch(errors => this.onError(errors));
    }

    initSteps() {
        let steps = [];
        if (!this.subscriptionId) {
            steps.push({ label: 'Login', value: StepTypes.LOGIN });
            if (!this.hasOnlyDigitalProducts) {
                steps.push({ label: 'Delivery', value: StepTypes.DELIVERY });
            }
        }
        steps.push({ label: 'Billing', value: StepTypes.BILLING });
        steps.push({ label: 'Confirmation', value: StepTypes.CONFIRMATION });
        this.steps = steps;
    }

    //
    // data accessors
    //

    getSubscriptionById(subId) {
        return new Promise((resolve, reject) => {
            getSubscriptionById({ subId: subId })
                .then(subscription => { resolve(subscription) })
                .catch(error => { reject([error.body.message]); })
        });
    }

    getNewSubscription(offerId, email, source, password, waiveActivationFee, sourceCampaign) {
        return new Promise((resolve, reject) => {
            getNewSubscription({ offerId: offerId, email: email, source: source, password: password, waiveActivationFee: waiveActivationFee, sourceCampaign })
                .then(subscription => { resolve(subscription) })
                .catch(error => { reject([error.body.message]) })
        });
    }

    getOfferById(offerId) {
        return new Promise((resolve, reject) => {
            getOfferById({ offerId: offerId })
                .then(offer => { resolve(offer); })
                .catch(error => { reject([error.body.message]) })
        });
    }
}