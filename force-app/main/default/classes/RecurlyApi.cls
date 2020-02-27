public with sharing class RecurlyApi {
    Recurly_API_Key__mdt recurlyApiKey;
    
    public RecurlyApi() {
        this.recurlyApiKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];
    }

    public void updateAccount(RecurlyApiObjects.Account account) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/accounts/' + account.account_code);
        request.setMethod('PUT');
        request.setBody(account.getXmlString());
        HttpResponse response = http.send(request);

        System.debug(response);
        System.debug(response.getBody());
    
        if (response.getStatusCode() == 200) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to update the account');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

    public RecurlyApiObjects.Invoice getInvoice(String invoiceId) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/invoices/' + invoiceId);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            XMLSerializer serializer = new XMLSerializer();
            System.debug(response.getBody());
            return (RecurlyApiObjects.Invoice)serializer.deSerialize(response.getBody(), RecurlyApiObjects.Invoice.class);
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to create the purchase');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

    public void createPurchase(RecurlyApiObjects.Purchase purchase) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/purchases');
        request.setMethod('POST');
        request.setBody(purchase.getXmlString());
        HttpResponse response = http.send(request);

        System.debug(purchase.getXmlString());
        System.debug(response);
        System.debug(response.getBody());

        if (response.getStatusCode() == 201) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to create the purchase');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

    public void refundInvoice(InvoiceRefund refund) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/invoices/' + refund.invoiceId + '/refund');
        request.setMethod('POST');
        request.setBody(refund.getXmlString());
        HttpResponse response = http.send(request);

        System.debug(response);
        System.debug(response.getBody());

        if (response.getStatusCode() == 201) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to create the refund');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

    public class InvoiceRefund {
        public String invoiceId {get;set;}
        public String refundMethod {get;set;}
        public Decimal amountInCents {get;set;}
        public List<RecurlyApiObjects.AdjustmentDetails> adjustments {get;set;}

        public InvoiceRefund(String invoiceId, Decimal amountInCents) {
            this.invoiceId = invoiceId;
            this.amountInCents = amountInCents;
            this.refundMethod = 'credit_first';
        }

        public InvoiceRefund(String invoiceId, List<RecurlyApiObjects.AdjustmentDetails> adjustments) {
            this.invoiceId = invoiceId;
            this.adjustments = adjustments;
            this.refundMethod = 'credit_first';
        }

        public String getXmlString() {
            String xml = '<invoice>';
            xml += '<refund_method>' + refundMethod + '</refund_method>';
            if (amountInCents != null) {
                xml += '<amount_in_cents>' + String.valueOf(amountInCents) + '</amount_in_cents>';
            }
            else if (adjustments != null) {
                xml += '<line_items>';
                for (RecurlyApiObjects.AdjustmentDetails adj : adjustments) {
                    xml += '<adjustment>';
                    xml += '<uuid>' + String.valueOf(adj.uuid) + '</uuid>';
                    xml += '<quantity>' + String.valueOf(adj.quantity) + '</quantity>';
                    xml += '</adjustment>';
                }
                xml += '</line_items>';
            }
            xml += '</invoice>';
            return xml;
        }
    }


    public static List<String> parseErrors(XmlStreamReader reader) {
        List<String> errors = new List<String>();
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                if (reader.getLocalName() == 'error') {
                    String error = parseError(reader);
                    errors.add(error);
                }
            }
            
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return errors;
    }
    
    public static String parseError(XmlStreamReader reader) {
        String error;
        Boolean isSafeToGetNextXmlElement = true;
        while (isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                String text = reader.getText();
                error = text.substring(0, 1).toUpperCase() + text.substring(1);
            }

            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return error;
    }
}