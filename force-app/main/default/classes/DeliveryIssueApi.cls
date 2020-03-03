@RestResource(urlMapping='/deliveryissue/*')
global with sharing class DeliveryIssueApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            DeliveryIssueInput input = (DeliveryIssueInput)JSON.deserialize(RestContext.request.requestbody.toString(), DeliveryIssueInput.class);
            validate(input);
            createTransaction(input);
            res.responseBody = Blob.valueOf(JSON.serialize(true));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void createTransaction(DeliveryIssueInput input) {
        String resolution = (input.Resolution == 'R' ? 'Deliver' : 'Credit');
        DeliveryServiceIssueController.createDeliveryIssue(input.SubId, input.Compliant, resolution, Date.parse(input.IncidentDate));
    }

    private static void validate (DeliveryIssueInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class DeliveryIssueInput {
        public String SubId {get;set;}
        public String Resolution {get;set;}
        public String IncidentDate {get;set;}
        public String Compliant {
            get {
                if (Compliant == 'R') {
                    return 'Delivery';
                } else if (Compliant == 'C') {
                    return 'Credit';
                }
                return Compliant;
            }
            set;
        }

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            if (String.isEmpty(Compliant)) {
                return false;
            }
            if (String.isEmpty(Resolution)) {
                return false;
            }
            if (String.isEmpty(IncidentDate)) {
                return false;
            }
            return true;
        }
    }
}