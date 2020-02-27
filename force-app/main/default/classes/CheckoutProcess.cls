public with sharing class CheckoutProcess {
    private Subscription__c subscription;

    private static final String INVALID_DELIVERY_ADDRESS = 'Invalid delivery address';
    private static final String INVALID_MELISSA_RESPONSE = 'Melissa response is invalid';
    private static final String MELISSA_SUCCESS_RESPONSE_CODE = 'AS01';
    
    private Map<Id, recurly_v2__Recurly_Account__c> recurlyAccountById {
        get {
            if (recurlyAccountById == null) {
                recurlyAccountById = new Map<Id, recurly_v2__Recurly_Account__c>(subscription.Recurly_Accounts__r);
            }
            return recurlyAccountById;
        } private set;
    }

    private Account account {
        get {
            if (account == null) {
                account = (subscription.subscription_Account__c != null) ? AccountDataAccessor.getAccountById(subscription.subscription_Account__c) : null;
            }
            return account;
        } private set;
    }

    private Contact contact {
        get {
            if (contact == null) {
                contact = (subscription.Contact__c != null) ? ContactDataAccessor.getContactById(subscription.Contact__c) : null;
            }
            return contact;
        } private set;
    }

    private Offer__c offer {
        get {
            if (offer == null) {
                offer = (subscription.subscription_Offer__c != null) ? OfferDataAccessor.getOfferById(subscription.subscription_Offer__c) : null;
            }
            return offer;
        } private set;
    }

    private List<Delivery_Schedule__c> deliverySchedules {
        get {
            if (deliverySchedules == null) {
                deliverySchedules = DeliveryScheduleDataAccessor.getDeliveryScheduleBySubId(subscription.Id);
            }
            return deliverySchedules;
        } private set;
    }

    private Delivery_Address__c deliveryAddress {
        get {
            if (deliveryAddress == null) {
                deliveryAddress = (!deliverySchedules.isEmpty() && deliverySchedules[0].Delivery_Address__c != null) ? DeliveryAddressDataAccessor.getById(deliverySchedules[0].Delivery_Address__c) : null;
            }
            return deliveryAddress;
        } private set;
    }

    private SubscriptionCampaign subscriptionCampaign {
        get {
            if (subscriptionCampaign == null) {
                subscriptionCampaign = new SubscriptionCampaign(subscription);
            }    
            return subscriptionCampaign;
        } 
        set;
    }

    private RecurlyApi recurlyApi {
        get {
            if (recurlyApi == null) {
                recurlyApi = new RecurlyApi();
            }
            return recurlyApi;
        }
        private set;
    }

    public CheckoutProcess(Id subId) {
        subscription = SubscriptionDataAccessor.getSubscriptionById(subId);
    }

    public string updateDeliveryAddress(Map<String, String> address) {
        if (deliveryAddress == null) {
            deliveryAddress = new Delivery_Address__c();
        }

        setDeliveryAddress(address);
        upsert deliveryAddress;

        if (deliverySchedules.isEmpty()) {
            createDefaultDeliverySchedules();
            if (!deliverySchedules.isEmpty()) {
                insert deliverySchedules;
            }
        } else {
            for (Delivery_Schedule__c schedule : deliverySchedules) {
                schedule.Status__c = 'Active';
            }
            update deliverySchedules;
        }

        return DeliveryAddressDataAccessor.getById(deliveryAddress.Id).Melissa_Response__c;
    }

    public string updateBillingAddress(Map<String, String> address) {
        contact.FirstName = address.get('firstName');
        contact.LastName = address.get('lastName');

        account.Name = address.get('lastName') + ' Household';
        account.BillingStreet = address.get('street');
        account.BillingCity = address.get('city');
        account.BillingState = address.get('state');
        account.BillingCountry = address.get('country');
        account.BillingPostalCode = address.get('postalCode');

        update contact;
        update account;

        return AccountDataAccessor.getAccountById(account.Id).Melissa_Data_Address_Result_Code__c;
    }

    public Boolean hasValidDeliveryAddress() {
        if (deliveryAddress == null) {
            throw new GenericException(INVALID_DELIVERY_ADDRESS);
        }
        if (String.isEmpty(deliveryAddress.Melissa_Response__c)) {
            throw new GenericException(INVALID_MELISSA_RESPONSE);
        }
        return deliveryAddress.Melissa_Response__c.contains(MELISSA_SUCCESS_RESPONSE_CODE);
    }

    public void saveAgreement(String signatureUrl) {
        if (subscription.SignatureURL__c != null) { 
            String fileData = signatureUrl.split(',')[1].replace(' ','+');
            Blob fileContent = EncodingUtil.base64Decode(fileData);

            Attachment attach = new Attachment();
            attach.Body = fileContent;
            attach.Name = 'SignatureImage-' + System.now() + '.png';
            attach.ParentId = subscription.Id;
            attach.ContentType = 'png';
            insert attach;

            subscription.SignatureURL__c = signatureUrl;
            subscription.SignatureAttachmentURL__c = '/servlet/servlet.FileDownload?file=' + attach.Id;
            update subscription;
        }
    }

    public Id createRecurlyAccount() {
        recurly_v2__Recurly_Account__c newRecurlyAccount = new recurly_v2__Recurly_Account__c(
            recurly_v2__Account__c = account.Id,
            Subscription__c = subscription.Id
        );
        insert newRecurlyAccount;
        return newRecurlyAccount.Id;
    }

    public void submitPayment(CheckoutPaymentInformation payment) {
        System.debug(payment);
        payment.validate();
        recurly_v2__Recurly_Account__c recurlyAccount = recurlyAccountById.get(payment.accountId);
        if (payment.sendBill) {
            subscription.subscription_Current_Period_Ends_At__c = Date.today();
            subscription.Outstanding_Credit__c = 0;
            update subscription;
        }

        if (payment.processPayment) {
            RecurlyApiObjects.Purchase purchase = getNewPurchase(recurlyAccount.recurly_v2__Code__c, payment);
            recurlyApi.createPurchase(purchase);
            adjustSubscription(payment.subscriptionAmount);
        } 

        if (payment.enableEzPay) {
            recurlyApi.updateAccount(getRecurlyAccount(recurlyAccount.recurly_v2__Code__c, payment));
            subscription.subscription_Auto_Renew__c = true;
            subscription.Auto_Renew_Recurly_Account__c = recurlyAccount.Id;
            subscription.One_Time_Tip_Amount__c = payment.tipType == 'one-time' ? payment.tipAmount : 0;
            subscription.Auto_Renew_Tip__c = payment.tipType == 'automatic' ? payment.tipAmount : 0;
            update subscription;
        }
    }

    private void adjustSubscription(Decimal amount) {
        subscriptionCampaign.setCheckoutCompleteCampaign();
        subscription.Outstanding_Credit__c = ((subscription.Outstanding_Credit__c != null) ? subscription.Outstanding_Credit__c : 0) + amount;
        subscription.subscription_Current_Period_Started_At__c = (subscription.subscription_Current_Period_Started_At__c != null) ? subscription.subscription_Current_Period_Started_At__c : Date.today();
        CreditCalculatorController.ApplyAdjustment(new List<Subscription__c>{subscription});
        subscription.subscription_Status__c = 'Active';
        update subscription;
    }

    private Decimal getPaymentAmount() {
        if (subscription.Waive_Activation_Fee__c) {
            return subscription.Renewal_Amount__c;
        } 
        return subscription.Subscription_Amount__c;
    }

    private Boolean hasActiveSubscription() {
        return contact.Subscriptions__r != null && !contact.Subscriptions__r.isEmpty();
    }

    private void setDeliveryAddress(Map<String, String> address) {
        deliveryAddress.Address_Street__c = address.get('street');
        deliveryAddress.Address_City__c = address.get('city');
        deliveryAddress.Address_State__c = address.get('state');
        deliveryAddress.Zip__c = address.get('postalCode');
        deliveryAddress.Unit__c = address.get('unit');
        deliveryAddress.Address_House__c = null;
        deliveryAddress.Pre_Direction__c = null;
        deliveryAddress.Address_Suffix__c = null;
        deliveryAddress.Pre_Direction__c = null;
    }

    private Delivery_Schedule__c createDefaultSchedule(Offer_Product__c offerProduct) {
        return new Delivery_Schedule__c(
            Status__c = 'Active',
            Start_Date__c = Date.today(),
            End_Date__c = Date.newInstance(2999, 1, 1),
            Delivery_Address__c = deliveryAddress.Id, 
            subscription_Subscription__c = subscription.Id, 
            Offer_Product__c = offerProduct.Id,
            Day_Sunday__c = offerProduct.Sunday__c,
            Day_Monday__c = offerProduct.Monday__c,
            Day_Tuesday__c = offerProduct.Tuesday__c,
            Day_Wednesday__c = offerProduct.Wednesday__c,
            Day_Thursday__c = offerProduct.Thursday__c,
            Day_Friday__c = offerProduct.Friday__c,
            Day_Saturday__c = offerProduct.Saturday__c
        );
    }

    private void createDefaultDeliverySchedules() {
        if (offer.Offer_Products__r != null) {
            deliverySchedules = new List<Delivery_Schedule__c>();
            for (Offer_Product__c offerProduct : offer.Offer_Products__r) {
                if (!offerProduct.Is_Digital__c && !offerProduct.Is_Activation_Fee__c) {
                    deliverySchedules.add(createDefaultSchedule(offerProduct));
                }
            }
        }
    }

    private RecurlyApiObjects.Purchase getNewPurchase(String accountId, CheckoutPaymentInformation payment) {
        List<RecurlyApiObjects.AdjustmentDetails> adjustments = getAdjustments(payment);
        RecurlyApiObjects.BillingInfoInterface billingInfo = getBillingInfo(payment);
        return new RecurlyApiObjects.Purchase(accountId, adjustments, billingInfo);
    }

    private List<RecurlyApiObjects.AdjustmentDetails> getAdjustments(CheckoutPaymentInformation payment) {
        List<RecurlyApiObjects.AdjustmentDetails> adjustments = new List<RecurlyApiObjects.AdjustmentDetails>();
        adjustments.add(new RecurlyApiObjects.AdjustmentDetails((payment.subscriptionAmount * 100).intValue(), 1, 'Subscription Amount'));
        if (payment.tipAmount != null && payment.tipAmount > 0) {
            adjustments.add(new RecurlyApiObjects.AdjustmentDetails((payment.tipAmount * 100).intValue(), 1, 'Tip Amount'));
        }
        if (!payment.waiveActivationFee && offer != null && offer.Offer_Products__r != null) {
            for (Offer_Product__c product : offer.Offer_Products__r) {
                if (product.Is_Activation_Fee__c && product.Activation_Fee__c != null && product.Activation_Fee__c > 0) {
                    adjustments.add(new RecurlyApiObjects.AdjustmentDetails((product.Activation_Fee__c * 100).intValue(), 1, 'Activation Fee'));
                }
            }
        }
        return adjustments;
    }

    private RecurlyApiObjects.Account getRecurlyAccount(String accountCode, CheckoutPaymentInformation payment) {
        RecurlyApiObjects.Account acct = new RecurlyApiObjects.Account();
        acct.account_code = accountCode;
        acct.billing_info = getBillingInfo(payment);
        return acct;
    }

    private Boolean isDigitalOnly() {
        for (Offer_Product__c product : offer.Offer_Products__r) {
            if (!product.Is_Digital__c) {
                return false;
            }
        }
        return true;
    }

    private RecurlyApiObjects.BillingInfoInterface getBillingInfo(CheckoutPaymentInformation payment) {
        RecurlyApiObjects.TokenBillingInfo billingInfo = new RecurlyApiObjects.TokenBillingInfo();
        billingInfo.token_id = payment.billingToken;
        return billingInfo;
    }
}