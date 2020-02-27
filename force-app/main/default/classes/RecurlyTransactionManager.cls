public with sharing class RecurlyTransactionManager {
    Recurly_API_Key__mdt rAPIKey;
    
    public RecurlyTransactionManager() {
        this.rAPIKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];
    }

    public void createTransaction(RecurlyTransaction createTransaction) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(rAPIKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/transactions');
        request.setMethod('POST');
        request.setBody(createTransaction.getXmlString());
        HttpResponse response = http.send(request);

        System.debug(response);
        System.debug(response.getBody());

        if (response.getStatusCode() == 201) {
            return;
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to create the transaction');
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