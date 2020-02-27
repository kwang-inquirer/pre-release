@RestResource(urlMapping='/serviceinfo/*')
global with sharing class ServiceInfoApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            ServiceInfoInput input = (ServiceInfoInput)JSON.deserialize(RestContext.request.requestbody.toString(), ServiceInfoInput.class);
            validate(input);
            Delivery_Schedule__c deliverySchedule = DeliveryScheduleDataAccessor.getDeliveryScheduleBySubId(input.SubId)[0];
            res.responseBody = Blob.valueOf(JSON.serialize(new ServiceInfo(deliverySchedule)));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (ServiceInfoInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class ServiceInfoInput {
        public String SubId {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            return true;
        }
    }
}