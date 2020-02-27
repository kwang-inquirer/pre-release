import { LightningElement, api } from 'lwc';
 
export default class CheckoutConfirmation extends LightningElement {
    @api payment; 
    @api subscription;
    @api showEzPayMessage = false;
    @api showSubscriptionLink = false;
    @api showSubscriptionStartDate = false;
    @api showPaymentSubmittedMessage = false;
    @api showSubscriptionStartedMessage = false;

    get hasDeliveryDays() { return this.deliveryDays.length > 0 }
    get hasEndDate() { return this.subscription.subscription_Current_Period_Ends_At__c }
    get showTipAmount() { return this.payment.tipAmount || this.payment.tipAmount === 0 }
    get deliveryDays() { return this.getDeliveryDays() }
    get totalCharge() { return this.getTotalCharge() }
    get subscriptionUrl() { return '/' + this.subscription.Id }
    get tipLabel() { return (this.payment.tipType === 'one-time' ? 'One-time Tip Amount' : 'Tip Amount') }
    get subscriptionAmount() { return this.getFullAmount() }
    get endDateLabel() { return this.showEzPayMessage ? 'Next Payment Date' : 'End Date' }

    getDeliveryDays() {
        let days = [];
        if (this.subscription.Sunday__c) {
            days.push('Sunday');
        } 
        if (this.subscription.Monday__c) {
            days.push('Monday');
        } 
        if (this.subscription.Tuesday__c) {
            days.push('Tuesday');
        } 
        if (this.subscription.Wednesday__c) {
            days.push('Wednesday');
        } 
        if (this.subscription.Thursday__c) {
            days.push('Thurday');
        } 
        if (this.subscription.Friday__c) {
            days.push('Friday');
        } 
        if (this.subscription.Saturday__c) {
            days.push('Saturday');
        }
        return days.join(', ');
    }

    getTotalCharge() {
        let totalCharge = 0;
        if (this.payment.subscriptionAmount) {
            totalCharge += parseFloat(this.payment.subscriptionAmount);
        }
        if (this.payment.tipAmount) {
            totalCharge += parseFloat(this.payment.tipAmount);
        }
        return totalCharge;
    }

    getFullAmount() {
        if (this.subscription.Waive_Activation_Fee__c) {
            return this.subscription.Renewal_Amount__c;
        }
        return this.subscription.Subscription_Amount__c;
    }
}