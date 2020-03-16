public with sharing class RecurlyApi {
    Recurly_API_Key__mdt recurlyApiKey;

    public RecurlyApi() {
        this.recurlyApiKey = [SELECT label, API_Key__c, Subdomain__c from Recurly_API_Key__mdt where label = 'Private API Key'];
    }

    public void updateAccount(RecurlyApiObjects.Account account) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://' + recurlyApiKey.Subdomain__c + '.recurly.com/v2/accounts/' + account.account_code);
        request.setMethod('PUT');
        request.setBody(account.getXmlString());
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to update the account');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

    public void refundInvoice(String invoiceName, RecurlyApiObjects.Refund refund) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/json; charset=utf-8');
        request.setHeader('Accept','application/vnd.recurly.v2019-10-10+json');
        request.setHeader('Recurly-Version','recurly.v2019-10-10');
        request.setEndpoint('https://v3.recurly.com/sites/subdomain-' + recurlyApiKey.Subdomain__c + '/invoices/number-' + invoiceName + '/refund');
        request.setMethod('POST');
        request.setBody(JSON.serialize(refund, true));
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 201) {
             if (String.isNotEmpty(response.getBody())) {
                Map<String, Object> error = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                throw new GenericException((String)error.get('message'));
            } else {
                throw new GenericException('Failed to refund the invoice');
            }
        }
    }

    public void createPurchase(RecurlyApiObjects.Purchase purchase) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(recurlyApiKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://' + recurlyApiKey.Subdomain__c + '.recurly.com/v2/purchases');
        request.setMethod('POST');
        request.setBody(purchase.getXmlString());
        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 201) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to create the purchase');
        } else {
            List<String> errors = parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
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