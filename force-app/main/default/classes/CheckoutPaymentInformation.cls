public with sharing class CheckoutPaymentInformation {
    public String accountId {get;set;}
    public String paymentType {get;set;}
    public String tipType {get;set;}
    public String billingToken {get;set;}
    public Boolean sendBill {get;set;}
    public Boolean enableEzPay {get;set;}
    public Boolean processPayment {get;set;}
    public Boolean waiveActivationFee {get;set;}
    public Decimal tipAmount {get;set;}
    public Decimal subscriptionAmount {get;set;}

    private static final String INVALID_ACCOUNT_CODE = 'Account id was invalid';
    private static final String INVALID_PAYMENT_AMOUNT = 'Payment amount was invalid';
    private static final String INVALID_BILLING_TOKEN = 'Payment could not be validated';

    public Decimal totalAmount {
        get {
            Decimal total = 0;
            if (subscriptionAmount != null) {
                total += subscriptionAmount;
            }
            if (tipAmount != null) {
                total += tipAmount;
            }
            return total;
        }
        private set;
    }

    public void validate() {
        if (!sendBill) {
            if (subscriptionAmount == null || subscriptionAmount <= 0) {
                throw new GenericException(INVALID_PAYMENT_AMOUNT);
            }
            if (accountId == null) {
                throw new GenericException(INVALID_ACCOUNT_CODE);
            }
            if (paymentType == 'new' && billingToken == null) {
                throw new GenericException(INVALID_BILLING_TOKEN);
            }
        }
    }
}