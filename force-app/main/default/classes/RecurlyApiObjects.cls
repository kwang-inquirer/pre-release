public with sharing class RecurlyApiObjects {
    public interface BillingInfoInterface {
        Boolean isValid();
        String getXmlString();
    }

    public class Invoice {
        @AuraEnabled public InvoiceDetails invoice {get;set;}
    }

    public class InvoiceDetails {
        @AuraEnabled public String uuid {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public Integer invoice_number {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public Decimal total_in_cents {get;set;}
        @AuraEnabled public InvoiceLineItem line_items {get;set;}

        @AuraEnabled public Decimal total {
            get {
                if (total_in_cents == null) {
                    return 0;
                }
                return total_in_cents / 100;
            }
        }
    }

    public class InvoiceLineItem {
        @AuraEnabled public List<AdjustmentDetails> adjustment {get;set;}
    }

    public class AdjustmentDetails {
        @AuraEnabled public String uuid {get;set;}
        @AuraEnabled public String state {get;set;}
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public Decimal unit_amount_in_cents {get;set;}
        @AuraEnabled public Decimal total_in_cents {get;set;}

        @AuraEnabled public Decimal total {
            get {
                if (total_in_cents == null) {
                    return 0;
                }
                return total_in_cents / 100;
            }
        }

        public AdjustmentDetails(String uuid, Decimal quantity) {
            this.uuid = uuid;
            this.quantity = quantity;
        }

        public AdjustmentDetails(Decimal unit_amount_in_cents, Decimal quantity, String description) {
            this.unit_amount_in_cents = unit_amount_in_cents;
            this.quantity = quantity;
            this.description = description;
        }

        public String getXmlString() {
            String xml = '';
            xml += '<adjustment>';
            xml += '<quantity>' + String.valueOf(quantity) + '</quantity>';
            xml += '<unit_amount_in_cents>' + String.valueOf((unit_amount_in_cents).intValue()) + '</unit_amount_in_cents>';
            xml += '<description>' + description + '</description>';
            xml += '</adjustment>';
            return xml;
        }
    }
    
    public class Account {
        public String account_code {get;set;}
        public BillingInfoInterface billing_info {get;set;}

        public String getXmlString() {
            String xml = '';
            xml += '<account>';
            xml += '<account_code>' + account_code + '</account_code>';
            if (billing_info != null && billing_info.isValid()) {
                xml += billing_info.getXmlString();
            }
            xml += '</account>';
            System.debug(xml);
            return xml;
        }
    }


    public class Purchase {
        public String accountCode {get;set;}
        public String currencyIso {get;set;}
        public String collectionMethod {get;set;}
        public BillingInfoInterface billing_info {get;set;}
        public List<AdjustmentDetails> adjustments {get;set;}

        public Purchase(String accountCode, List<AdjustmentDetails> adjustments, BillingInfoInterface billing_info) {
            this.accountCode = accountCode;
            this.adjustments = adjustments;
            this.billing_info = billing_info;
            this.currencyIso = 'USD';
            this.collectionMethod = 'automatic';
        }

        public String getXmlString() {
            String xml = '<purchase>';
            xml += '<collection_method>' + collectionMethod + '</collection_method>';
            xml += '<currency>' + currencyIso + '</currency>';
            xml += '<account>';
            xml += '<account_code>' + accountCode + '</account_code>';
            if (billing_info != null && billing_info.isValid()) {
                System.debug('billing info valid');
                xml += billing_info.getXmlString();
            }
            xml += '</account>';
            if (this.adjustments != null) {
                xml += '<adjustments>';
                for (RecurlyApiObjects.AdjustmentDetails adj : adjustments) {
                    xml += adj.getXmlString();
                }
                xml += '</adjustments>';
            }
            xml += '</purchase>';
            System.debug(xml);
            return xml;
        }
    }

    public class TokenBillingInfo implements BillingInfoInterface {
        public String token_id {get;set;}

        public Boolean isValid() {
            System.debug(token_id);
            return String.isNotEmpty(token_id);
        }

        public String getXmlString() {
            String xml = '';
            xml += '<billing_info>';
            xml += '<token_id>' + token_id + '</token_id>';
            xml += '</billing_info>';
            return xml;
        }
    }

/*
    public class CardBillingInfo implements BillingInfoInterface {
        public String first_name {get;set;}
        public String last_name {get;set;}
        public String address1 {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String country {get;set;}
        public String card_number {get;set;}
        public String verification_value {get;set;}
        public String month {get;set;}
        public String year {get;set;}

        public String getXmlString() {
            String xml = '';
            xml += '<billing_info>';
            xml += '<first_name>' + first_name + '</first_name>';
            xml += '<last_name>' + last_name + '</last_name>';
            xml += '<address1>' + address1 + '</address1>';
            xml += '<city>' + city + '</city>';
            xml += '<state>' + state + '</state>';
            xml += '<zip>' + zip + '</zip>';
            xml += '<country>' + country + '</country>';
            xml += '<number>' + card_number + '</number>';
            xml += '<verification_value>' + verification_value + '</verification_value>';
            xml += '<month>' + month + '</month>';
            xml += '<year>' + year + '</year>';
            xml += '</billing_info>';
            return xml;
        }
    }

    public class BankBillingInfo implements BillingInfoInterface {
        public String name_on_account {get;set;}
        public String address1 {get;set;}
        public String city {get;set;}
        public String state {get;set;}
        public String zip {get;set;}
        public String country {get;set;}
        public String account_type {get;set;}
        public String account_number {get;set;}
        public String routing_number {get;set;}

        public String getXmlString() {
            String xml = '';
            xml += '<billing_info>';
            xml += '<name_on_account>' + name_on_account + '</name_on_account>';
            xml += '<address1>' + address1 + '</address1>';
            xml += '<city>' + city + '</city>';
            xml += '<state>' + state + '</state>';
            xml += '<zip>' + zip + '</zip>';
            xml += '<country>' + country + '</country>';
            xml += '<account_type>' + account_type + '</account_type>';
            xml += '<account_number>' + account_number + '</account_number>';
            xml += '<routing_number>' + routing_number + '</routing_number>';
            xml += '</billing_info>';
            return xml;
        }
    }
*/
}