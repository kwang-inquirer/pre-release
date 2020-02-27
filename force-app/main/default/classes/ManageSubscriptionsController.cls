public without sharing class ManageSubscriptionsController {

    public List<Email_Subscriber__c> emailSubscribersToUpdate {get; set;}
    public List<SubWrapper> emailSubscriptions {get; set;}
    public String contactID {get; set;}
    public String listID {get; set;}
    public String subscriberid {get; set;}
    public String status {get; set;}
    public String unSubscribeAllStatus {get; set;}
    public String message {get;set;}

    public ManageSubscriptionsController() {
        contactID = ApexPages.currentPage().getParameters().get('cid');
        listID = ApexPages.currentPage().getParameters().get('listid');

        emailSubscribersToUpdate = [SELECT id, name, Contact__c,Email_Subscription__c,Email_Subscription__r.Name ,Status__c,Unsubscribe_Date__c FROM Email_Subscriber__c WHERE Contact__c=:contactID AND Email_Subscription__c=:listID ];
        system.debug(emailSubscribersToUpdate.size());
        contactID = ApexPages.currentPage().getParameters().get('cid');

        UpdateSubscriptions();

    }

    public void UpdateSubscriptions(){
        emailSubscriptions = new List<SubWrapper>();
        for(Email_Subscription__c es:[SELECT id, name, (Select id, Contact__c,Email_Subscription__c, Name ,Status__c,Unsubscribe_Date__c from Email_Subscribers__r WHERE Contact__c =:contactID) FROM Email_Subscription__c order by Name ASC])
        {
            SubWrapper sw = new SubWrapper();
            sw.subscriptionID = es.id;
            sw.subscriptionName = es.Name;
            system.debug('-----' + es.Email_Subscribers__r.size());
            if(es.Email_Subscribers__r!=null && es.Email_Subscribers__r.size()>0) {
                if(es.Email_Subscribers__r[0].Status__c == 'Subscribed')
                {
                    sw.subscriptionStatus = 'Subscribed';
                    sw.subscriberId = es.Email_Subscribers__r[0].Id;
                }
                else{
                    sw.subscriptionStatus = 'Unsubscribed';
                    sw.subscriberId = es.Email_Subscribers__r[0].Id;
                }
            }
            else{
                sw.subscriptionStatus = 'No Preference';
            }
            system.debug(sw);
            emailSubscriptions.add(sw);
        }

    }


    public void unsubscribe(){

        for(Email_Subscriber__c ES:emailSubscribersToUpdate){
            ES.Status__c = 'Unsubscribed';
            ES.Unsubscribe_Date__c = system.today();
        }

        update emailSubscribersToUpdate;

        UpdateSubscriptions();

    }
    //Actions for Unsubscribe from all link on the bottom of VFP
    public void unsubscribeToAll(){

        try {
            Contact c = new Contact(id = contactid);
            c.HasOptedOutOfEmail = true;
            update c;


            List<Email_Subscriber__c> ESS = [SELECT id, name, Contact__c,Email_Subscription__c,Status__c,Unsubscribe_Date__c FROM Email_Subscriber__c WHERE Contact__c = :contactID AND Status__c != 'Unsubscribed'];
            for (Email_Subscriber__c ES : ESS) {
                ES.Status__c = 'Unsubscribed';
                ES.Unsubscribe_Date__c = system.today();
            }

            update ESS;

            unSubscribeAllStatus = 'You have been unsubscribed from all communications.';
            message = 'Your preferences have been updated.';
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            message = 'An error occurred: ' + ex.getMessage();
        }
    }

    public void UpdateStatus(){
        system.debug(subscriberid);
        system.debug(status);

//        Email_Subscriber__c es = new Email_Subscriber__c();
//        if(subscriberid!=null && subscriberid!='') {
//            es.id = subscriberid;
//        }
//        es.Status__c = status;
//        if (status == 'Subscribed') {
//            es.Subscribe_Date__c = system.today();
//        } else if (status == 'Unsubscribed') {
//            es.Unsubscribe_Date__c = system.today();
//        }
//        upsert es;

        for(SubWrapper sw:emailSubscriptions){
            if(sw.subscriberID == subscriberid)
            {
                sw.subscriptionStatus = status;
            }
        }

    }

    public void Submit(){
        try {
            List<Email_Subscriber__c> esToUpdate = new List<Email_Subscriber__c>();

            for(SubWrapper sw:emailSubscriptions){
                system.debug('---');
                system.debug(sw.subscriberId);
                system.debug(contactID);
                system.debug(sw.subscriptionID);
                Email_Subscriber__c es = new Email_Subscriber__c();
                es.id = sw.subscriberId;
                es.Contact__c = contactID;
                es.Email_Subscription__c = sw.subscriptionID;

                es.Status__c = sw.subscriptionStatus;
                if(sw.subscriptionStatus == 'Subscribed')
                {
                    es.Subscribe_date__c = system.today();
                }
                else if(sw.subscriptionStatus == 'Unsubscribed')
                {
                    es.Unsubscribe_date__c = system.today();
                }

                if(sw.subscriptionStatus !='No Preference'){
                    esToUpdate.add(es);
                }

            }


            upsert esToUpdate;
            message = 'Your preferences have been updated.';

            UpdateSubscriptions();
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
            message = ex.getMessage();
        }

    }


    public class SubWrapper{

        public String contactId {get;set;}
        public String subscriberID {get;set;}
        public String subscriptionName {get;set;}
        public String subscriptionID {get;set;}
        public String subscriptionStatus {get;set;}

        public SubWrapper(){

        }
    }
}