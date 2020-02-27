public class NewSubscriptionCmpController {
    @AuraEnabled
    public static recurly_v2__Recurly_Account__c getRecurlyAccount(){
        Id runningUser = UserInfo.getUserId();
        Id accountId;
        List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id IN (SELECT ContactId FROM User WHERE Id = :runningUser)];
        if(!contacts.isEmpty()){
            accountId = contacts[0].AccountId;
        }
        //only for testing
        accountId = '0010j00000NdbsfAAB';
        List<recurly_v2__Recurly_Account__c> rcAccounts = [SELECT Id, recurly_v2__Last_Four__c, 
                                                           Name,
                                                           recurly_v2__Code__c,
                                                           recurly_v2__Card_Type__c,
                                                           recurly_v2__Account__r.BillingStreet,
                                                           recurly_v2__Account__r.BillingCity,
                                                           recurly_v2__Account__r.BillingCountry,
                                                           recurly_v2__Account__r.BillingState,
                                                           recurly_v2__Billing_ID__c, 
                                                           recurly_v2__Account__r.BillingPostalCode,
                                                           recurly_v2__Billing_First_Name__c,
                                                           recurly_v2__Billing_Last_Name__c,
                                                           recurly_v2__Billing_Account_ID__c, 
                                                           recurly_v2__Billing_Valid__c
                                                           FROM recurly_v2__Recurly_Account__c
                                                           WHERE recurly_v2__Account__c = :accountId AND recurly_v2__Billing_Valid__c  = TRUE LIMIT 1];
        if(!rcAccounts.isEmpty()){
            return rcAccounts[0];
        }
        return null;
    }
    
    @AuraEnabled
    public static Subscription__c getSubscriptionDetail(Id subscriptionId){
        List<Subscription__c> subs = [SELECT Id, Name, Subscription_Amount__c 
                                      FROM Subscription__c WHERE subscription_Status__c = 'Active'];
        if(!subs.isEmpty()){
            return subs[0];
        }
        return null;
    }
    @AuraEnabled
    public static Boolean updatePaymentInformation(String jsonObject){
        Recurly_API_Key__mdt rAPIKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];
        
        /*Example with Stored Billing Info*/
        system.debug(jsonObject);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonObject);
        //USE: (String)m.get('creditCardNumber')
        /*Example with new Billing Info*/
        String xmlBody = '';
        xmlBody += '<billing_info>';
        xmlBody += '<first_name>' + (String)m.get('firstName') + '</first_name>';
        xmlBody += '<last_name>' + (String)m.get('lastName') + '</last_name>';
        xmlBody += '<number>' + (String)m.get('cardNumber') + '</number>';
        xmlBody += '<verification_value>' + (String)m.get('ccv') + '</verification_value>';
        xmlBody += '<month>' + (String)m.get('month') + '</month>';
        xmlBody += '<year>' + (String)m.get('year') + '</year>';
        //xmlBody += '<ip_address>127.0.0.1</ip_address>';
        //xmlBody += '<three_d_secure_action_result_token_id>3DS_TOKEN_ID</three_d_secure_action_result_token_id>';
        xmlBody += '</billing_info>';
        
        System.debug('xmlBody: ' + xmlBody);
        system.debug(xmlBody);
        Blob bl =  Blob.valueOf(rAPIKey.API_Key__c);
        String cid = EncodingUtil.base64Encode(bl);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ cid );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://:subdomain.recurly.com/v2/accounts/' + (String)m.get('accountCode') + '/billing_info');
        request.setMethod('POST');
        request.setBody(xmlBody);
       /* HttpResponse response = http.send(request);
        
        system.debug(response.getStatusCode());
        system.debug(response.getBody());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Success
            system.debug(response.getBody());
        }
        else{
            
            XmlStreamReader reader = new XmlStreamReader(response.getBody());
            
            boolean isSafeToGetNextXmlElement = true;
            boolean errorFound = false;
            while(isSafeToGetNextXmlElement) {
                system.debug('reader.getLocalName() --- ' + reader.getLocalName());
                if ('error' == reader.getLocalName() && !errorFound) {
                    errorFound = true;
                }
                
                if(errorFound && 'description' == reader.getLocalName())
                {
                    system.debug('reader.getText() --- ' + reader.getText());
                    return false;//'Error: ' + reader.getText();
                }
                
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            
            
            return false;//'Error: ' + response.getBody();
        }
        */
        return true;
    }
    @AuraEnabled
    public static Boolean submitPaymentExistingAccount(String accountCode){
        Recurly_API_Key__mdt rAPIKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];
        
        /*Example with Stored Billing Info*/
        String xmlBody;
        xmlBody = '<transaction>';
        xmlBody += '<amount_in_cents>100</amount_in_cents>';
        xmlBody += '<currency>USD</currency>';
        xmlBody += '<account>';
        xmlBody += '<account_code>' + accountCode + '</account_code>';
        xmlBody += '</account>';
        xmlBody += '</transaction>';
        
        system.debug(xmlBody);
        Blob bl =  Blob.valueOf(rAPIKey.API_Key__c);
        String cid = EncodingUtil.base64Encode(bl);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ cid );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/transactions');
        request.setMethod('POST');
        request.setBody(xmlBody);
        HttpResponse response = http.send(request);
        
        system.debug(response.getStatusCode());
        system.debug(response.getBody());
        // If the request is successful, parse the JSON response.
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            //Success
            system.debug(response.getBody());
        }
        else{
            
            XmlStreamReader reader = new XmlStreamReader(response.getBody());
            
            boolean isSafeToGetNextXmlElement = true;
            boolean errorFound = false;
            while(isSafeToGetNextXmlElement) {
                system.debug('reader.getLocalName() --- ' + reader.getLocalName());
                if ('error' == reader.getLocalName() && !errorFound) {
                    errorFound = true;
                }
                
                if(errorFound && 'description' == reader.getLocalName())
                {
                    system.debug('reader.getText() --- ' + reader.getText());
                    return false;//'Error: ' + reader.getText();
                }
                
                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }
            
            
            return false;//'Error: ' + response.getBody();
        }
        
        return true;
    }
}