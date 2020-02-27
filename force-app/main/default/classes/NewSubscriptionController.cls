public with sharing class NewSubscriptionController {

    public List<String> newspaperList { get; set; }
    public List<String> locationList { get; set; }
    public String selectedNewspaper { get; set; }
    public String selectedLocation { get; set; }
    public List<Campaign> promotionList { get; set; }
    //public List<String> premiumList { get; set; }
    public List<String> paymentType { get; set; }
    public List<String> cardType { get; set; }
    public User currentUser { get; set; }
    public boolean alreadySelected { get; set; }



    public NewSubscriptionController() {

        newspaperList = new List<String>();
        locationList = new List<String>();

        List<Newspaper__c> news = [SELECT id, Name from Newspaper__c];
        List<Location__c> locs = [SELECT id, Name from Location__c];
        //newspaperList.add('Test Newspaper');
        //newspaperList.add('Test Newspaper2');
        for (Newspaper__c n : news) {

            newspaperList.add(n.Name);
        }


        for (Location__c l : locs) {

            locationList.add(l.Name);
        }

        promotionList = new List<Campaign>();
        //List<Vendor_Promotions__c> promotions = [SELECT id, Name__c, promotion__r.Promotion_Name__c from Vendor_Promotions__c];
        List<Campaign> promotions =[SELECT id, Name FROM Campaign WHERE IsActive = true];
        for (Campaign c : promotions) {

            promotionList.add(c);
        }

        

        paymentType = new List<String>();
        paymentType.add('Credit Card');

        cardType = new List<String>();
        cardType.add('American Express');
        cardType.add('Discover');
        cardType.add('Mastercard');
        cardType.add('Visa');

        alreadySelected = False;
        currentUser = [Select id, newspaper__c, location__c, partner_selling_date__c from user where id = :UserInfo.getUserId()];
        system.debug(currentUser.newspaper__c);
        system.debug(currentUser.location__c);
        system.debug(currentUser.partner_selling_date__c);
        Date newDate = currentUser.partner_selling_date__c == null ? null : date.newinstance(currentUser.partner_selling_date__c.year(), currentUser.partner_selling_date__c.month(), currentUser.partner_selling_date__c.day());
        system.debug(newDate == system.today());
        if (newDate == system.today() && currentUser.newspaper__c != null && currentUser.location__c != null) {
            selectedNewspaper = currentUser.newspaper__c;
            selectedLocation = currentUser.location__c;
            alreadySelected = True;
        }

        system.debug(selectedNewspaper);
        system.debug(selectedLocation);
        system.debug(alreadySelected);

    }

    @RemoteAction
    public static List<Campaign_Offer__c> queryOffers(String promotionId){

        system.debug(promotionId);
        return [SELECT Id, Name,Campaign__c, Offer__c, Offer__r.Offer_Name__c FROM Campaign_Offer__c where Campaign__c =: promotionId];
    }

    @RemoteAction
    public static List<Offer__c> queryPremiums(String offerId){

        system.debug(offerId);
        return [SELECT Id, Name,Premium_Products__c, Premium_Products__r.Name, Total_Amount__c FROM Offer__c where Id =: offerId];
    }



    @RemoteAction
    public static void updateSelectedPaperAndLocation(String paper, String location) {
        system.debug('start updateSelectedPaperAndLocation');
        //Update selected paper and location fields on user record
        User u = new User();
        u.id = UserInfo.getUserId();
        u.newspaper__c = paper;
        u.location__c = location;
        u.partner_selling_date__c = system.now();
        update u;

    }


    @RemoteAction
    public static Subscription__c createRecords(String subscriptionDataJSON, String signatureURL, Boolean emptySignature ) {

        system.debug('subscriptionDataJSON = ' + subscriptionDataJSON);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(subscriptionDataJSON);

        Account account = new Account();
        account.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        account.Name = (String) m.get('deliveryFirstName') + ' ' + (String) m.get('deliveryLastName');
        account.Phone = (String) m.get('deliveryPhone');
        account.BillingStreet = (String) m.get('billingAddress1');
        account.BillingCity = (String) m.get('billingCity');
        account.BillingState = (String) m.get('billingState');
        account.BillingPostalCode = (String) m.get('billingZipCode');
        account.ShippingStreet = (String) m.get('deliveryAddress1');
        account.ShippingCity = (String) m.get('deliveryCity');
        account.ShippingState = (String) m.get('deliveryState');
        account.ShippingPostalCode = (String) m.get('deliveryZipCode');
        account.OwnerId = UserInfo.getUserId();

        insert account;


        Contact contact = new Contact();
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Subscriber Contact').getRecordTypeId();
        contact.FirstName = (String) m.get('deliveryFirstName');
        contact.LastName = (String) m.get('deliveryLastName');
        contact.AccountId = account.id;
        contact.Phone = (String) m.get('deliveryPhone');
        contact.Email = (String) m.get('deliveryEmail');
        contact.MailingStreet = (String) m.get('deliveryAddress1');
        contact.MailingCity = (String) m.get('deliveryCity');
        contact.MailingState= (String) m.get('deliveryState');
        contact.MailingPostalCode = (String) m.get('deliveryZipCode');
        contact.OwnerId = UserInfo.getUserId();

        insert contact;

        Subscription__c subscription = new Subscription__c();
        subscription.subscription_Account__c = account.id;
        subscription.Contact__c = contact.id;
        subscription.subscription_Offer__c =(String) m.get('offerSelect');
        if(!emptySignature)
        {
            subscription.SignatureURL__c = signatureURL;
        }

        insert subscription;

        if(subscription.SignatureURL__c!=null)
        {
            String fileData = subscription.SignatureURL__c.split(',')[1].replace(' ','+');
            blob fileContent = EncodingUtil.base64Decode(fileData);

            Attachment attach = new Attachment();
            attach.Body = fileContent;
            attach.Name = 'SignatureImage-'+system.now()+'.png';
            attach.ParentId = subscription.id;
            attach.ContentType = 'png';
            insert attach;

            subscription.SignatureAttachmentURL__c = '/servlet/servlet.FileDownload?file=' + attach.id;
            update subscription;

        }

        //String ccResponse = NewSubscriptionController.processCreditCard(account.id, m); //Moved to separate VF Remoting call to avoid 'pending work' error

        NewSubscriptionController.GenerateReceipt(subscription.id);

        return [SELECT id, Name, Subscription_Account__c FROM Subscription__c WHERE id = :subscription.id];
    }
    // method has to be a future method because subscription query in SubscriptionReceiptController returns no rows even with valid id
    @future(Callout=true)
    public static void GenerateReceipt(Id subscriptionId) {
        PageReference pdf = Page.SubscriptionReceipt;
        pdf.setRedirect(true);
        pdf.getParameters().put('id', subscriptionid);
        system.debug('subid ' + subscriptionid);

        Attachment attach = new Attachment();
        Blob body;
//        try {
        body = pdf.getContent();
//        } catch (VisualforceException e) {
//            body = Blob.valueOf('Error : ' + e);
//        }

        attach.Body = body;
        attach.Name = Datetime.now().format('yyyy-MM-dd HH:mm') + ' ' + 'Subscription Receipt' + '.pdf';
        attach.IsPrivate = false;
        attach.ParentId = subscriptionId;
        insert attach;
        system.debug(attach.id);

    }

    @RemoteAction
    public static void sendEmail(id subscriptionid, String emailAddress){

        Subscription__c sub = [Select id, subscription_Account__c, Contact__c from Subscription__c where id =: subscriptionid];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        emailTemplate et= [SELECT id, name, Subject, Body  from EmailTemplate where name ='Partner Community: subscription sign up info' ];

        email.setTemplateId(et.id);
        email.setToAddresses(new list<String> {emailAddress});
        email.setTargetObjectId(sub.Contact__c);
        email.setWhatId(sub.subscription_Account__c);


        Attachment receiptAttach = [SELECT id, Name, body from Attachment where ParentID =:subscriptionid and Name like '%Subscription Receipt%' ORDER BY CreatedDate DESC limit 1];
        Messaging.EmailFileAttachment fileAttach = new  Messaging.EmailFileAttachment();
        fileAttach.setFileName(receiptAttach.name);
        fileAttach.setBody(receiptAttach.body);

        email.setFileAttachments(new list<Messaging.EmailFileAttachment>{fileAttach});

        messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});


    }


    @RemoteAction
    public static String processCreditCard(String acctId, String subscriptionDataJSON)
    {
        system.debug(acctId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(subscriptionDataJSON);
        Recurly_API_Key__mdt rAPIKey = [SELECT label, API_Key__c from Recurly_API_Key__mdt where label = 'Private API Key'];

        recurly_v2__Recurly_Account__c rac = [Select id,
                                                Name,
                                                recurly_v2__Code__c,
                                                recurly_v2__Account__r.BillingStreet,
                                                recurly_v2__Account__r.BillingCity,
                                                recurly_v2__Account__r.BillingCountry,
                                                recurly_v2__Account__r.BillingState,
                                                recurly_v2__Account__r.BillingPostalCode,
                                                recurly_v2__Billing_First_Name__c,
                                                recurly_v2__Billing_Last_Name__c
                                            from recurly_v2__Recurly_Account__c
                                            where recurly_v2__Account__c=:acctId];

        system.debug('rac ==='  +rac.id);
        system.debug('acctId ==='  +acctId);
        recurly_v2__Recurly_Subscription__c recSub = [SELECT id,recurly_v2__Account__c,recurly_v2__Plan_Code__c from recurly_v2__Recurly_Subscription__c where recurly_v2__Recurly_Account__c =:rac.id];

        system.debug('account_code>+rac.Name ==='  +rac.Name);
        system.debug('recSub.recurly_v2__Plan_Code__c = ' + recSub.recurly_v2__Plan_Code__c);
        system.debug('recurly account code = ' + rac.recurly_v2__Code__c);
        system.debug('cc = ' + (String)m.get('creditCardNumber'));
        String xmlBody;
        xmlBody = '<purchase>';
        xmlBody += '<collection_method>automatic</collection_method><currency>USD</currency><customer_notes>Some notes for the customer.</customer_notes>';
        xmlBody += '<terms_and_conditions>Our company terms and conditions.</terms_and_conditions><vat_reverse_charge_notes>Vat reverse charge notes.</vat_reverse_charge_notes>';
        xmlBody += '<account>';
        xmlBody += '<account_code>'+rac.Name +'</account_code>';
        xmlBody += '<billing_info>';
        xmlBody += '<address1>'+rac.recurly_v2__Account__r.BillingStreet + '</address1>';
        xmlBody += '<city>'+rac.recurly_v2__Account__r.BillingCity +'</city>';
        xmlBody += '<country>' + rac.recurly_v2__Account__r.BillingCountry +'</country>';
        xmlBody += '<first_name>'+rac.recurly_v2__Billing_First_Name__c +'</first_name>';
        xmlBody += '<last_name>'+rac.recurly_v2__Billing_last_Name__c +'</last_name>';
        xmlBody += '<month>'+(String)m.get('expMonth')+'</month>';
        xmlBody += '<number>'+(String)m.get('creditCardNumber')+'</number>';
        xmlBody += '<state>'+rac.recurly_v2__Account__r.BillingState +'</state>';
        xmlBody += '<year>'+(String)m.get('expYear')+'</year>';
        xmlBody += '<zip>' + rac.recurly_v2__Account__r.BillingPostalCode+'</zip>';
        xmlBody += '</billing_info>';
        xmlBody += '</account>';
        xmlBody += '<subscriptions>';
        xmlBody += '<subscription>';
        xmlBody += '<plan_code>00000test</plan_code>';
        xmlBody += '<unit_amount_in_cents>1000</unit_amount_in_cents>';
        xmlBody += '</subscription>';
        xmlBody += '</subscriptions>';
        xmlBody += '</purchase>';

        system.debug(xmlBody);
        Blob bl =  Blob.valueOf(rAPIKey.API_Key__c);
        String cid = EncodingUtil.base64Encode(bl);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization','Basic '+ cid );
        request.setHeader('Content-Type','application/xml; charset=utf-8');
        request.setHeader('Accept','application/xml');
        request.setHeader('X-Api-Version','2.20');
        request.setEndpoint('https://inquirer.recurly.com/v2/purchases');
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
                    return 'Error: ' + reader.getText();
                }

                if (reader.hasNext()) {
                    reader.next();
                } else {
                    isSafeToGetNextXmlElement = false;
                    break;
                }
            }

            //Delete the previously created Account to remove the Account, Contact, and Subscription records
            if(acctId!=null)
            {
                delete [Select id from Account where id=:acctId];
            }

            return 'Error: ' + response.getBody();
        }

        return null;
    }

}