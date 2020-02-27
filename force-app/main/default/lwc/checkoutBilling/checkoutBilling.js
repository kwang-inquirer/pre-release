import { LightningElement, api, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import submitPayment from '@salesforce/apex/CheckoutController.submitPayment';
import getUserInfo from '@salesforce/apex/CheckoutController.getUserInfo';
import createRecurlyAccount from '@salesforce/apex/CheckoutController.createRecurlyAccount';
import saveBillingAddress from '@salesforce/apex/CheckoutController.saveBillingAddress';

import RECURLYJS_VFP_URL from '@salesforce/label/c.RECURLYJS_VFP_URL';
import POSTMATE from '@salesforce/resourceUrl/Postmate';

export default class CheckoutBilling extends LightningElement {
    @track handshake;
    @track child;
    @track token;
    @track userInfo;
    @track tipAmount;
    @track errorMessage;
    @track newAccountId;
    @track bankInformation;
    @track customPaymentAmount;
    @track selectedAccountId;
    @track existingPaymentMethodOptions;
    
    @track loading = false;
    @track recurlyJsInit = false;
    @track postmateInitialized = false;

    @track tipType = 'automatic';
    @track paymentType = 'card';
    @track paymentMethod = 'new';
    @track newPaymentShowStyle = 'slds-hide';

    @track paymentTypeOptions = [{ label: 'Credit Card', value: 'card' }, { label: 'ACH Bank', value: 'bank' }];
    @track tipTypeOptions = [{ label: 'Automatic', value: 'automatic' }, { label: 'One-time', value: 'one-time' }];

    @api label;
    @api address;
    @api tipAmount;
    @api subscription;
    @api disabled = false;
    @api showBillMe = false;
    @api editPayment = false;
    @api showPrevious = false;
    @api enableAutoPay = false;
    @api processPayment = false;
    @api waiveActivationFee = false;
    @api updateBillingInfo = false;
    @api isNewSubscription = false;
    @api showIndividualStreet = false;
    @api showAgreementBeforeSubmit = false;

    get totalCharge() { return this.getTotalCharge() }
    get paymentAmount() { return this.getPaymentAmount() }
    get canEditPayment() { return this.editPayment }
    get showPaymentMethods() { return this.paymentMethods.length > 1 }
    get paymentMethodExisting() { return this.paymentMethod === 'existing' }
    get paymentMethodNew() { return this.paymentMethod === 'new' }
    get paymentMethodBillMe() { return this.paymentMethod === 'bill' }
    get paymentTypeCard() { return this.paymentType === 'card' }
    get paymentTypeBank() { return this.paymentType === 'bank' }
    get paymentMethods() { return this.getPaymentMethods() }
    get accountId() { return (this.selectedAccountId) ? this.selectedAccountId : this.newAccountId }
    get nameOnAccount() { return this.address.firstName + ' ' + this.address.lastName }
    get recurlyJsStyle() { return this.paymentMethod === 'new' && this.recurlyJsInit ? '' : 'slds-hide' }

    handleSubmitClicked() { this.submitBilling() }
    handlePreviousClicked() { this.previous() }
    handleAddressChange(event) { this.address = event.detail }
    handleCardChange(event) { this.cardInformation = event.detail }
    handleBankChange(event) { this.bankInformation = event.detail }
    handlePaymentAmountChange(event) { this.customPaymentAmount = event.detail.value }
    handlePaymentMethodChange(event) { this.methodChange(event) }
    handleExistingPaymentMethodChange(event) { this.selectedAccountId = event.detail.value }
    handleTipAmountChange(event) { this.tipAmount = event.detail.value }
    handleTipTypeChange(event) { this.tipType = event.detail.value }
    handlePaymentTypeChange(event) { this.paymentTypeChange(event); }

    connectedCallback() {
        this.processSubscription();
        getUserInfo().then(userInfo => {
            this.userInfo = userInfo;
        });

        if (!this.postmateInitialized) {
            loadScript(this, POSTMATE + '/postmate/postmate.min.js').then(() => {
                this.postmateInitialized = true;
            })
        }
    }

    renderedCallback() {
        if (!this.recurlyJsInit && this.postmateInitialized && this.paymentMethod === 'new') {
            this.loadNewPaymentFrame();
        }
    }

    paymentTypeChange(event) {
        this.paymentType = event.detail.value;
        if (this.paymentType === 'card') {
            this.child.call('showCard', null);
        } else {
            this.child.call('hideCard', null);
        }
    }

    methodChange(event) {
        this.paymentType = 'card';
        this.paymentMethod = event.detail.value;
        this.recurlyJsInit = false;
    }

    submitBilling() {
        this.errorMessage = null;
        this.loading = true;
        this.validateAmount()
            .then(() => this.validateNewPayment())
            .then(() => this.validateSignature())
            .then(() => this.getToken())
            .then(() => this.saveAddress())
            .then(() => this.saveSignature())
            .then(() => this.saveRecurlyAccount())
            .then(() => this.submitPayment())
            .then(() => this.finishBilling())
            .catch(error => this.handleErrors(error))
    }


    loadNewPaymentFrame() {
        if (this.postmateInitialized) {
            this.recurlyJsInit = true;
            this.newPaymentShowStyle = 'slds-hide';

            // Create recurlyjs iframe
            this.handshake = new Postmate({
                container: this.template.querySelector(':scope .vfFrame'), 
                url: RECURLYJS_VFP_URL, 
                classListArray: ["recurly"] 
            }).then(child => {
                this.child = child;
                this.newPaymentShowStyle = '';
                child.frame.frameBorder = 0;
                child.frame.scrolling = 0;
                child.frame.style.width = '100%';
            })
        }
    }

    getToken() {
        return new Promise((resolve, reject) => {
            if (this.paymentMethod !== 'new') {
                resolve();
            } else if (this.paymentType === 'bank') {
                this.getBankToken().then(token => {
                    this.token = token;
                    resolve();
                }).catch(error => reject(error))
            } else {
                this.getCardToken().then(token => {
                    this.token = token;
                    resolve();
                }).catch(error => reject(error))
            }
        });
    }

    getCardToken() {
        return new Promise((resolve, reject) => {
            this.child.call('setCard', JSON.parse(JSON.stringify({ address: this.address })));
            this.child.get('getCardToken').then(res => {
                if (res.error) {
                    reject(res.error);
                } else {
                    this.token = res.token;
                    resolve(res.token);
                }
            }).catch(error => {
                reject(error);
            })
        });
    }

    getBankToken() {
        return new Promise((resolve, reject) => {
            this.child.call('setBank', JSON.parse(JSON.stringify({ details: this.bankInformation, address: this.address })));
            this.child.get('getBankToken').then(res => {
                if (res.error) {
                    reject(res.error);
                } else {
                    resolve(res.token);
                }
            }).catch(error => {
                reject(error);
            })
        });
    }

    previous() {
        const selectedEvent = new CustomEvent('previous', { detail: { payment: this.getPaymentDetails(), address: this.address } });
        this.dispatchEvent(selectedEvent);
    }

    handleErrors(error) {
        this.loading = false;
        if (Array.isArray(error)) {
            this.errorMessage = error[0];
        } else if (error && error.message && typeof error === 'object') {
            this.errorMessage = error.message;
        } else if (error && error.body && typeof error === 'object') {
            this.errorMessage = error.body.message;
        } else {
            this.errorMessage = error;
        }
    }

    getPaymentMethods() {
        let paymentMethods = [{ label: 'New Payment Method', value: 'new' }];
        if (this.existingPaymentMethodOptions && this.existingPaymentMethodOptions.length > 0) {
            paymentMethods.push({ label: 'Existing Payment Method', value: 'existing' });
        }
        if (this.showBillMe) {
            paymentMethods.push({ label: 'Bill Me', value: 'bill' });
        }
        return paymentMethods;
    }

    getPaymentAmount() {
        if (this.customPaymentAmount) {
            return this.customPaymentAmount;
        }
        return this.getFullAmount();
    }

    getFullAmount() {
        if (this.subscription.Waive_Activation_Fee__c) {
            return this.subscription.Renewal_Amount__c;
        }
        return this.subscription.Subscription_Amount__c;
    }

    getTotalCharge() {
        let totalCharge = 0;
        if (this.paymentAmount) {
            totalCharge += parseFloat(this.paymentAmount);
        }
        if (this.tipAmount) {
            totalCharge += parseFloat(this.tipAmount);
        }
        return totalCharge;
    }

    setExistingPaymentMethod(id) {
        this.selectedAccountId = id;
    }

    getPaymentDetails() {
        return {
            billingToken: this.token ? this.token.id : null,
            tipType: this.tipType,
            tipAmount: this.tipAmount,
            paymentType: this.selectedAccountId ? 'existing' : 'new',
            accountId: this.accountId,
            enableEzPay: this.enableAutoPay,
            processPayment: this.processPayment && this.paymentMethod !== 'bill',
            waiveActivationFee: this.waiveActivationFee,
            subscriptionAmount: this.paymentAmount,
            sendBill: this.paymentMethod === 'bill',
        };
    }

    processSubscription() {
        if (this.subscription && this.subscription.Recurly_Accounts__r) {
            let options = [{ label: 'New Payment Method', value: null }];
            for (let i = 0; i < this.subscription.Recurly_Accounts__r.length; i++) {
                const acct = this.subscription.Recurly_Accounts__r[i];
                if (acct && acct.recurly_v2__Card_Type__c && acct.recurly_v2__Last_Four__c) {
                    const label = '[' + acct.recurly_v2__Card_Type__c + '] ....' + acct.recurly_v2__Last_Four__c;
                    options.push({ label: label, value: acct.Id });
                } else {
                    this.newAccountId = acct.Id;
                }
            }
            if (options.length > 1) {
                this.existingPaymentMethodOptions = options;
                this.paymentMethod = 'existing';
            }
        }
    }

    finishBilling() {
        this.loading = false;
        const selectedEvent = new CustomEvent('next', { detail: { payment: this.getPaymentDetails(), address: this.address } });
        this.dispatchEvent(selectedEvent);
    }

    saveRecurlyAccount() {
        return new Promise((resolve, reject) => {
            if (this.paymentMethod === 'bill' || this.selectedAccountId) {
                resolve();
            } else {
                createRecurlyAccount({ subId: this.subscription.Id })
                    .then(accountId => {
                        this.newAccountId = accountId;
                        resolve();
                    })
                    .catch(error => reject(error))
            }
        });
    }

    submitPayment() {
        return new Promise((resolve, reject) => {
            var payment = this.getPaymentDetails();
            submitPayment({ subId: this.subscription.Id, paymentJson: JSON.stringify(payment) })
                .then(() => resolve())
                .catch(error => reject(error))
        });
    }

    validateSignature() {
        return new Promise((resolve, reject) => {
            if (this.showAgreementBeforeSubmit) {
                this.template.querySelector('c-checkout-signature').validate()
                    .then(() => resolve())
                    .catch(() => reject('Failed to validate the signature'))
            } else {
                resolve();
            }
        });
    }

    validateNewPayment() {
        return new Promise((resolve, reject) => {
            if (this.paymentMethod === 'existing') {
                resolve();
            } else {
                this.template.querySelector('c-checkout-address').validate().then(() => {
                    if (this.paymentMethod === 'bill' || this.paymentType === 'card') {
                        resolve();
                    } else if (this.paymentType === 'bank') {
                        this.template.querySelector('c-checkout-payment-bank').validate()
                            .then(() => {
                                resolve();
                            })
                            .catch(() => reject('Failed to validate the bank information'))
                    }
                }).catch(() => reject('Failed to validate the billing address information'))
            }
        });
    }

    validateAmount() {
        return new Promise((resolve, reject) => {
            const isCommunityUser = this.userInfo && this.userInfo.Profile && this.userInfo.Profile.UserLicense && this.userInfo.Profile.UserLicense.Name.toLowerCase().includes('community');
            if (!isCommunityUser || (isCommunityUser && this.paymentAmount >= this.getFullAmount())) {
                resolve();
            } else {
                reject('Failed to validate the payment amount');
            }
        });
    }

    saveSignature() {
        return new Promise((resolve, reject) => {
            if (this.showAgreementBeforeSubmit) {
                this.template.querySelector('c-checkout-signature').save()
                    .then(() => resolve())
                    .catch(() => reject('Failed to save the signature'))
            } else {
                resolve();
            }
        });
    }

    saveAddress() {
        return new Promise((resolve, reject) => {
            saveBillingAddress({ subId: this.subscription.Id, address: this.address })
                .then(() => resolve())
                .catch(() => reject('Failed to save the address'))
        });
    }
}