import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoice from '@salesforce/apex/RecurlyInvoiceController.getInvoice';
import refundByAmount from '@salesforce/apex/RecurlyInvoiceController.refundByAmount';
import refundByLineItems from '@salesforce/apex/RecurlyInvoiceController.refundByLineItems';

const lineItemColumns = [
    { label: 'Description', fieldName: 'recurly_v2__Line_Item_Description__c' },
    { label: 'Amount', fieldName: 'recurly_v2__Amount__c', type: 'currency', typeAttributes: { currencyCode: 'USD' }, cellAttributes: { alignment: 'left' } },
    { label: 'Refunded', fieldName: 'Refunded__c', type: 'boolean', cellAttributes: { alignment: 'left' } }
];

export default class RecurlyInvoiceRefundModal extends LightningElement {
    @track invoice;
    @track lineItems;
    @track customAmount;
    @track selectedRows;
    @track warningMessage;
    @track showModal = false;
    @track lineItemColumns = lineItemColumns;

    @api open(invoiceId) { 
        this.lineItems = null;
        this.invoice = null;
        this.customAmount = null;
        this.selectedRows = null;
        this.warningMessage = null;
        this.showModal = false;
        this.fetchInvoice(invoiceId) 
    }

    get invalidRefund() { return !this.hasValidInput() }
    get hasSelected() { return this.selectedRows && this.selectedRows.length > 0 }
    get disableRefundCustomAmount() { return (this.invoice.Refund_Type__c === 'Line Items') || (this.selectedRows && this.selectedRows.length > 0); }
    get disableRefundLineItems() { return this.invoice.Refund_Type__c === 'Amount'; }

    get refundAmount() {
        if (this.selectedRows && this.selectedRows.length > 0) {
            return this.getSelectedLineItemTotal();
        }
        return this.customAmount;
    }

    setCustomAmount(event) {
        this.customAmount = event.detail.value;
        this.validateRefundAmount();
    }

    setSelected(event) {
        this.customAmount = null;
        this.selectedRows = event.detail.selectedRows;
        this.validateRefundAmount();
    }

    validateRefundAmount() {
        const inputCmp = this.template.querySelector('.refundAmount');
        if (this.refundAmount && this.refundAmount <= 0) {
            inputCmp.setCustomValidity('Amount must be greater than zero');
        } else if (this.refundAmount && this.refundAmount > this.invoice.recurly_v2__Total__c) {
            inputCmp.setCustomValidity('Amount cannot be more than the original amount');
        } else {
            inputCmp.setCustomValidity('');
        }
        inputCmp.reportValidity();
    }

    close() {
        this.showModal = false;
    }

    hasValidInput() {
        if (!this.refundAmount) {
            return false;
        }
        if (this.refundAmount <= 0 || this.refundAmount > this.invoice.recurly_v2__Total__c) {
            return false;
        }
        if (!this.customAmount && this.selectedRows && this.selectedRows.length <= 0) {
            return false;
        }
        if (!this.customAmount && this.selectedRowsHasRefundedLineItem()) {
            return false;
        }
        return true;
    }

    selectedRowsHasRefundedLineItem() {
        let hasRefundedLineItem = false;
        if (this.selectedRows) {
            this.selectedRows.forEach(row => {
                if (row.Refunded__c) {
                    hasRefundedLineItem = true;
                }
            });
        }
        return hasRefundedLineItem;
    }

    getSelectedLineItemTotal() {
        if (this.selectedRows) {
            let amount = 0;
            this.selectedRows.forEach(row => {
                amount += row.recurly_v2__Amount__c;
            });
            return amount;
        }
        return 0;
    }

    refund() {
        if (this.selectedRows && this.selectedRows.length > 0) {
            this.refundByLineItems();
        } else if (this.refundAmount) {
            this.refundByAmount();
        }
    }

    refundByAmount() {
        refundByAmount({ invoiceId: this.invoice.Id, amount: this.refundAmount })
            .then(() => {
                this.showToast('Refund Successful', 'The refund has successfully been created', 'success');
                this.close();
            })
            .catch(error => {
                const errorMessage = error.body.message ? error.body.message : 'Failed to create the refund';
                this.showToast('Refund Failure', errorMessage, 'error');
            });
    }

    refundByLineItems() {
        let lineItems = [];
        this.selectedRows.forEach(row => {
            lineItems.push(row.Id);
        });
        refundByLineItems({ invoiceId: this.invoice.Id, lineItems: lineItems })
            .then(() => {
                this.showToast('Refund Successful', 'The refund has successfully been created', 'success');
                this.close();
            })
            .catch(error => {
                const errorMessage = error.body.message ? error.body.message : 'Failed to create the refund';
                this.showToast('Refund Failure', errorMessage, 'error');
            });
    }

    fetchInvoice(invoiceId) {
        this.invoiceId = invoiceId;
        getInvoice({ invoiceId: invoiceId })
            .then(invoice => {
                this.invoice = invoice;
                if (invoice.Refund_Type__c === 'Line Items') {
                    this.warningMessage = 'Unable to refund by custom amount due to a previous refund by line items';
                } else if (invoice.Refund_Type__c === 'Amount') {
                    this.warningMessage = 'Unable to refund by line items due to a previous refund by amount';
                }
                this.showModal = true;
            })
            .catch(error => {
                this.showModal = false;
                this.showToast(error.body.message, null, 'error');
            })
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}