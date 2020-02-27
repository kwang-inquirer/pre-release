public with sharing class CheckoutSubscriptionCreator {
    public static Subscription__c getNewSubscription(String offerId, String email, String source, String password, Boolean waiveActivationFee, String SourceCampaign) {
        Offer__c offer = OfferDataAccessor.getOfferById(offerId);
        Subscription__c subscription = getSubscription(offer, email, source, password, waiveActivationFee, SourceCampaign);
        new SubscriptionCampaign(subscription).setNewSubscriptionCampaign();
        return subscription;
    }

    private static Subscription__c getSubscription(Offer__c offer, String email, String source, String password, Boolean waiveActivationFee, String SourceCampaign) {
        List<Subscription__c> existingSubscriptions = SubscriptionDataAccessor.getSubscriptionsByEmail(email);
        if (!existingSubscriptions.isEmpty()) {
            return getExistingSubscription(existingSubscriptions, offer, waiveActivationFee, SourceCampaign);
        }
        return createDefaultSubscription(offer, email, source, password, waiveActivationFee, SourceCampaign);
    }

    private static Subscription__c getExistingSubscription(List<Subscription__c> existingSubscriptions, Offer__c offer, Boolean waiveActivationFee, String SourceCampaign) {
        for (Subscription__c subscription : existingSubscriptions) {
            if (subscription.subscription_Status__c == 'Active') {
                throw new GenericException('This email already has an active subscription');
            } 
        }
        Subscription__c subscription = existingSubscriptions[0];
        setSubscription(subscription, offer, null, waiveActivationFee, subscription.subscription_Status__c, SourceCampaign);
        update subscription;
        System.debug('here');
        if (subscription.subscription_Status__c != 'New' && isDigitalOnly(offer)) {
            createStartRestartTransaction(offer, subscription);
        }
        return SubscriptionDataAccessor.getSubscriptionById(subscription.Id);
    }

    private static Auth0Manager.AuthUser getAuth0Account(String email, String password) {
        Auth0Manager authManager = new Auth0Manager();
        List<Auth0Manager.AuthUser> authAccounts = authManager.getUsersByEmail(email);
        if (authAccounts.isEmpty()) {
            Auth0Manager.AuthUser authAccount = authManager.createUser(new Map<String, Object>{'email' => email, 'password' => password});
            if (authAccount != null) {
                authAccounts.add(authAccount);
            }
        }
        if (authAccounts.isEmpty()) {
            throw new GenericException('Failed to create authentication account');
        }
        return authAccounts[0];
    }

    private static Subscription__c createDefaultSubscription(Offer__c offer, String email, String source, 
				String password, Boolean waiveActivationFee, String SourceCampaign) {
        // If existing contact exists then use that otherwise create a new default contact/account
        List<Contact> existingContacts = ContactDataAccessor.getContactsByEmail(email);
        if (existingContacts.isEmpty()) {
            Auth0Manager authManager = new Auth0Manager();
            Auth0Manager.AuthUser authAccount = getAuth0Account(email, password);

            Account subscriberAccount = new Account(Name = 'New Subscriber Household');
            insert subscriberAccount;

            Contact subscriberContact = new Contact(FirstName = 'New', LastName = 'Subscriber', Email = email, AccountId = subscriberAccount.Id, Auth0_User_Id__c = (String)authAccount.user_id);
            insert subscriberContact;

            existingContacts.add(subscriberContact);
        }

        Contact subscriberContact = existingContacts[0];
        subscriberContact.Source__c = source;
        upsert subscriberContact;
        
        // Create new default subscription
        Subscription__c subscription = new Subscription__c();
        setSubscription(subscription, offer, subscriberContact, waiveActivationFee, 'New', SourceCampaign);
        insert subscription;

        if (isDigitalOnly(offer)) {
            createStartRestartTransaction(offer, subscription);
        }

        return SubscriptionDataAccessor.getSubscriptionById(subscription.Id);
    }

    private static void createStartRestartTransaction(Offer__c offer, Subscription__c subscription) {
        try {
            Transaction_Type__c vrType = TransactionDataAccessor.getFirstTransactionTypeByCode(System.Label.SubscriptionNewStartRestartTransactionCode);
            insert new Transaction_Log__c(Memo__c = 'Start/Restart Digital Only', Offer__c = offer.Id, First_Date__c = Date.Today(), Last_Date__c = Date.Today(), Subscription__c = subscription.Id, Category__c = 'Start', Transaction_Type__c = vrType.Id);
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    private static void setSubscription(Subscription__c subscription, Offer__c offer, Contact subscriberContact, Boolean waiveActivationFee, String status, String SourceCampaign) {
        subscription.subscription_Status__c = status;
        subscription.subscription_Offer__c = offer.Id;
        subscription.Waive_Activation_Fee__c = waiveActivationFee;
		subscription.Source_Campaign__c = SourceCampaign;
        if (subscriberContact != null) {
            subscription.Contact__c = (subscriberContact != null) ? subscriberContact.Id : null;
            subscription.subscription_Account__c = (subscriberContact != null) ? subscriberContact.AccountId : null;
        }
        if (offer.Free_Trial__c) {
            subscription.subscription_Status__c = 'Active';
            subscription.subscription_Current_Period_Started_At__c = Date.today();
            subscription.subscription_Current_Period_Ends_At__c = Date.today().addDays(Integer.valueOf(Label.Free_Trial_Days));
        }
        if (!isDigitalOnly(offer)) {
            subscription.Ready_for_DSI__c = true;
        }
    }

    private static Boolean isDigitalOnly(Offer__c offer) {
        for (Offer_Product__c product : offer.Offer_Products__r) {
            if (!product.Is_Digital__c) {
                return false;
            }
        }
        return true;
    }
}