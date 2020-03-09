@RestResource(urlMapping='/checkout/*')
global with sharing class CheckoutRestApi {

  @HttpPost
  global static void submitPayment(Id subscriptionId, CheckoutPaymentInformation payment) {
    new CheckoutProcess(subscriptionId).submitPayment(payment);
  }
}
