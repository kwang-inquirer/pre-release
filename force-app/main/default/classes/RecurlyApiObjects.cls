public with sharing class RecurlyApiObjects {
    public interface BillingInfoInterface {
        Boolean isValid();
        String getXmlString();
    }

    public class Refund {
        public String type {get;set;}
        public Decimal amount {get;set;}
        public List<RefundLineItem> line_items {get;set;}

        public Refund(Decimal amount) {
            this.type = 'amount';
            this.amount = amount;
        }

        public Refund(List<RefundLineItem> line_items) {
            this.type = 'line_items';
            this.line_items = line_items;
        }
    }

    public class RefundLineItem {
        public String id {get;set;}
        public Decimal quantity {get;set;}

        public RefundLineItem(String id, Decimal quantity) {
            this.id = id;
            this.quantity = quantity;
        }
    }

    public class AdjustmentDetails {
        @AuraEnabled public String description {get;set;}
        @AuraEnabled public Decimal quantity {get;set;}
        @AuraEnabled public Decimal unit_amount_in_cents {get;set;}

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
            return xml;
        }
    }

    public class TokenBillingInfo implements BillingInfoInterface {
        public String token_id {get;set;}

        public Boolean isValid() {
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
}