public with sharing class RecurlyTransaction {
    public String amount_in_cents {get;set;}
    public String account_code {get;set;}

    public String getXmlString() {
        String xmlString = '';
        xmlString += '<transaction>';
        xmlString += '<amount_in_cents>' + amount_in_cents + '</amount_in_cents>';
        xmlString += '<currency>USD</currency>';
        xmlString += '<account>';
        xmlString += '<account_code>' + account_code + '</account_code>';
        if (billing_info != null) {
            xmlString += billing_info.getXmlString();
        }
        xmlString += '</account>';
        xmlString += '</transaction>';
        return xmlString;
    }

    public BillingInfoInterface billing_info {get;set;}

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

    public interface BillingInfoInterface {
        String getXmlString();
    }
}