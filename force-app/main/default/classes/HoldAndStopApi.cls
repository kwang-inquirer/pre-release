@RestResource(urlMapping='/holdandstop/*')
global with sharing class HoldAndStopApi {
    @HttpPost
    global static void post() {
        RestResponse res = RestContext.response;
        try {
            HoldAndStopInput input = (HoldAndStopInput)JSON.deserialize(RestContext.request.requestbody.toString(), HoldAndStopInput.class);
            validate(input);
            Transaction_Log__c vacationHold = createVacationHold(input.SubId, input.Type, input.StartDate, input.EndDate, input.StopReason);
            Transaction_Log__c updatedTransaction = TransactionDataAccessor.getTransaction(vacationHold.Id);
            res.responseBody = Blob.valueOf(JSON.serialize(new HoldAndStop(updatedTransaction)));
        } catch (GenericException e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseError(e.getMessage())));
        } catch (Exception e) {
            System.debug(e.getMessage() + e.getStackTraceString());
            res.statusCode = 500;
        }
    }

    private static void validate (HoldAndStopInput input) {
        if (!input.isValid()) {
            throw new GenericException('Invalid input');
        }
    }

    private static Transaction_Log__c createVacationHold(String subId, String type, String startDateStr, String endDateStr, String reason) {
        Date startDate = (type != 'R') ? Date.parse(startDateStr) : null;
        Date stopDate = (type != 'S') ? Date.parse(endDateStr) : null;
        String stopReason = (type != 'V') ? reason : null;
        Transaction_Log__c vacationHold = new Transaction_Log__c(
            RecordTypeId = Schema.SObjectType.Transaction_Log__c.getRecordTypeInfosByDeveloperName().get('Vacation').getRecordTypeId(),
            Subscription__c = subId,
            Stop_Type__c = getStopReasonDesc(stopReason),
            Sub_Type__c = getTypeDesc(type),
            Start_Date__c = startDate,
            Stop_Date__c = stopDate,
            Stop_Reason__c = stopReason,
            Category__c = 'Vacation Pack'
        );
        insert vacationHold;
        return vacationHold;
    }

    private static String getTypeDesc(String type) {
        switch on type {
            when 'S' {
                return 'Stop Only';
            }
            when 'R' {
                return 'Restart Only';
            }
            when 'V' {
                return 'Vacation';
            }
            when else {
                return null;
            }
        }
    }

    private static String getStopReasonDesc(String stopReason) {
        switch on stopReason {
            when 'N' {
                return 'NIE';
            }
            when 'R' {
                return 'Regular Stop/Start';
            }
            when else {
                return null;
            }
        }
    }

    private class HoldAndStopInput {
        public String SubId {get;set;}
        public String Type {get;set;}
        public String StartDate {get;set;}
        public String EndDate {get;set;}
        public String StopReason {get;set;}

        public Boolean isValid() {
            if (String.isEmpty(SubId)) {
                return false;
            }
            if (String.isEmpty(Type)) {
                return false;
            }
            if (String.isEmpty(StartDate)) {
                return false;
            }
            if (String.isEmpty(EndDate)) {
                return false;
            }
            return true;
        }
    }

    private class HoldAndStop {
        public String ActualStart {get;set;}
        public String ActualRestart {get;set;}


        public HoldAndStop(Transaction_Log__c vacationHold) {
            this.ActualStart = String.ValueOf(vacationHold.Actual_Start__c);
            this.ActualRestart = String.ValueOf(vacationHold.Actual_Restart__c);
        }
    }
}