import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getInvoice from '@salesforce/apex/RecurlyInvoiceController.getInvoice';
import refundByAmount from '@salesforce/apex/RecurlyInvoiceController.refundByAmount';
import refundByLineItems from '@salesforce/apex/RecurlyInvoiceController.refundByLineItems';

const lineItemColumns = [
    { label: 'Description', fieldName: 'description' },
    { label: 'Amount', fieldName: 'total', type: 'currency', typeAttributes: { currencyCode: 'USD' } }
];

export default class RecurlyInvoiceRefundModal extends LightningElement {
    @track invoice;
    @track lineItems;
    @track refundAmount;
    @track selectedRows;
    @track showModal = false;
    @track lineItemColumns = lineItemColumns;

    @api open(invoiceId) { this.fetchInvoice(invoiceId) }

    get invalidRefund() { return !this.refundAmount && (!this.selectedRows || (this.selectedRows && this.selectedRows.length === 0)) }
    get hasSelected() { return this.selectedRows && this.selectedRows.length > 0 }

    setRefundAmount(event) {
        this.refundAmount = event.detail.value;
    }

    setSelectedIds(event) {
        this.selectedRows = event.detail.selectedRows;
    }

    close() {
        this.showModal = false;
        this.invoice = null;
    }

    refund() {
        if (this.selectedRows && this.selectedRows.length > 0) {
            this.refundByLineItems();
        } else if (this.refundAmount) {
            this.refundByAmount();
        }
    }

    refundByAmount() {
        refundByAmount({ invoiceNumber: this.invoice.invoice_number, amount: this.refundAmount })
            .then(() => {
                this.showToast('Refund Successful', 'The refund has successfully been created', 'success');
                this.close();
            })
            .catch(error => {
                console.log(JSON.stringify(error.body.message));
                const errorMessage = error.body.message ? error.body.message : 'Failed to create the refund';
                this.showToast('Refund Failure', errorMessage, 'error');
            });
    }

    refundByLineItems() {
        let lineItemIds = [];
        this.selectedRows.forEach(row => {
            lineItemIds.push(row.uuid);
        });
        refundByLineItems({ invoiceNumber: this.invoice.invoice_number, lineItemIds: lineItemIds })
            .then(() => {
                this.showToast('Refund Successful', 'The refund has successfully been created', 'success');
                this.close();
            })
            .catch(error => {
                console.log(JSON.stringify(error));
                const errorMessage = error.body.message ? error.body.message : 'Failed to create the refund';
                this.showToast('Refund Failure', errorMessage, 'error');
            });
    }

    fetchInvoice(invoiceId) {
        this.invoiceId = invoiceId;
        getInvoice({ invoiceId: invoiceId })
            .then(invoice => {
                this.invoice = invoice.invoice;
                if (this.invoice.line_items) {
                    let items = [];
                    this.invoice.line_items.forEach(item => {
                        items.push(item.adjustment);
                    });
                    this.lineItems = items;
                }
                this.showModal = true;
            })
            .catch(error => {
                this.showModal = false;
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