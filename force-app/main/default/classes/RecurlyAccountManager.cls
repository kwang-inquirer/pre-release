public with sharing class RecurlyAccountManager {
    Recurly_API_Key__mdt rAPIKey;
    
    public RecurlyAccountManager() {
        this.rAPIKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];
    }

    public RecurlyAccount updateAccount(RecurlyAccount account) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(rAPIKey.API_Key__c)) );
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
            Dom.Document doc = new Dom.Document();
            doc.load(response.getBody());
            return (RecurlyAccount)XmlToJson.parseDocumentToObject(doc, RecurlyAccount.class);
        } else if (String.isEmpty(response.getBody())) {
            throw new GenericException('Failed to update the account');
        } else {
            List<String> errors = RecurlyTransactionManager.parseErrors(new XmlStreamReader(response.getBody()));
            throw new GenericException(String.join(errors, ', '));
        }
    }

/*
    public RecurlyAccount getAccount(String accountCode) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(rAPIKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/accounts/' + accountCode);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        System.debug('getAccount');
        System.debug(response);
        System.debug(response.getBody());

        if (response.getStatusCode() == 200) {
            Dom.Document doc = new Dom.Document();
            doc.load(response.getBody());
            return (RecurlyAccount)XmlToJson.parseDocumentToObject(doc, RecurlyAccount.class);
        } 
        return null;
    }
*/

/*
    public RecurlyAccount createAccount(RecurlyAccount account) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ EncodingUtil.base64Encode(Blob.valueOf(rAPIKey.API_Key__c)) );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/accounts');
        request.setMethod('POST');
        request.setBody(account.getXmlString());
        HttpResponse response = http.send(request);

        System.debug('createAccount');
        System.debug(response);
        System.debug(response.getBody());

        if (response.getStatusCode() == 201) {
            Dom.Document doc = new Dom.Document();
            doc.load(response.getBody());
            return (RecurlyAccount)XmlToJson.parseDocumentToObject(doc, RecurlyAccount.class);
        } 
        return null;
    }
*/
}