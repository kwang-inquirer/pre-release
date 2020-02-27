@RestResource(urlMapping='/route/*')
global with sharing class RouteApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            RouteInput input = (RouteInput)JSON.deserialize(RestContext.request.requestbody.toString(), RouteInput.class);
            validate(input);
            List<Delivery_Schedule__c> deliverySchedule = DeliveryScheduleDataAccessor.getCurrentDayDeliverySchedule(input.CustAccount, input.Route);
            if (deliverySchedule.isEmpty()) {
                throw new GenericException('No route found');
            }
            res.responseBody = Blob.valueOf(JSON.serialize(new Route(deliverySchedule[0])));
        } catch (GenericException e) {
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            res.statusCode = 500;
        }
    }

    private static void validate (RouteInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private class RouteInput {
        public String CustAccount {get;set;}
        public String Route {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(CustAccount)) {
                return false;
            }
            if (String.isEmpty(Route)) {
                return false;
            }
            return true;
        }
    }
}