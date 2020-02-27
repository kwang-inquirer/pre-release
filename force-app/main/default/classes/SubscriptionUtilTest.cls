/*
* -----------------------------------------------------------
* Apex Class Name: SubscriptionUtilTest
* -----------------------------------------------------------
* Description: Tests SubscriptionUtil.apxc
* -----------------------------------------------------------
* Created by: Mitchell McLaughlin, RelationEdge
*/
@isTest
private class SubscriptionUtilTest {
    @testSetup static void setup(){
        
    }
    @isTest static void shouldCreateRecurlySub() {
        Account account = new Account(
            Name = 'RelationEdge');
        insert account;
        recurly_v2__Recurly_Account__c recurlyAccount = new recurly_v2__Recurly_Account__c(
            recurly_v2__Account__c = account.Id
        );
        insert recurlyAccount;
        
        Subscription__c subscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdge',
            Delivery_Instructions__c = 'Throw it at the front door.',
            Outstanding_Credit__c = 20.25
        );
        insert subscription;
    }   
    @isTest static void shouldCreateRecurlyAccountAndSub(){
        
        Account account = new Account(
            Name = 'RelationEdge');
        insert account;
        Subscription__c subscription = new Subscription__c(
            subscription_Account__c = account.Id,
            Attention_Line__c = 'RelationEdge',
            Delivery_Instructions__c = 'Throw it at the front door.',
            Outstanding_Credit__c = 20.25
        );
        insert subscription;
        
    }
    
}