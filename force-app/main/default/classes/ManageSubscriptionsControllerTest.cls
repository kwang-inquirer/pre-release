@isTest
public with sharing class ManageSubscriptionsControllerTest {

    static testMethod void testManageSubController(){

        Id contactRecType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Subscriber Contact').getRecordTypeId();
        Id accRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();

        //Create Household Account
        Account a = new Account();
        a.name = 'Lady Test Household';
        a.RecordTypeId = accRecType;
        insert a;

        //Create Contact
        Contact c = new Contact();
        c.RecordTypeId = contactRecType;
        c.FirstName = 'Lady';
        c.LastName = 'Test';
        c.AccountId = a.id;
        insert c;

        //Create Email Subscription
        List<Email_Subscription__c> eSubscriptions = New List<Email_Subscription__c>();
        Email_Subscription__c subscription = New Email_Subscription__c();
        subscription.Name = 'Events';
        eSubscriptions.add(subscription);

        Email_Subscription__c subscription2 = New Email_Subscription__c();
        subscription2.Name = 'Promotions';
        eSubscriptions.add(subscription2);

        insert eSubscriptions;

        //Create Email Subscribers
        List<Email_Subscriber__c> eSubscribers = New List<Email_Subscriber__c>();
        Email_Subscriber__c subscriber = New Email_Subscriber__c();
        //subscriber.Name = 'Test Email Subscriber';
        subscriber.Email_Subscription__c = eSubscriptions[0].id;
        subscriber.Contact__c = c.id;
        subscriber.Subscribe_Date__c = system.today();
        subscriber.Status__c = 'Subscribed';

        eSubscribers.add(subscriber);

        Email_Subscriber__c subscriber2 = New Email_Subscriber__c();
        subscriber2.Email_Subscription__c = eSubscriptions[1].id;
        subscriber2.Contact__c = c.id;
        subscriber2.Subscribe_Date__c = system.today();
        subscriber2.Status__c = 'Subscribed';

        eSubscribers.add(subscriber2);
        insert eSubscribers;

        ManageSubscriptionsController cntrl = new ManageSubscriptionsController();
        cntrl.contactid = c.id;
        cntrl.UpdateSubscriptions();
        cntrl.unsubscribe();
        cntrl.unsubscribeToAll();
        cntrl.status = 'Subscribed';
        cntrl.subscriberid = subscriber.id;
        cntrl.UpdateStatus();
        cntrl.status = 'Unsubscribed';
        cntrl.subscriberid = subscriber.id;
        cntrl.UpdateStatus();
        cntrl.Submit();




    }
}