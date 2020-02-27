@isTest
private class CleanFlowErrorMessageTest {
    @isTest static void shouldCleanseString(){
        String myTestString = 'FIELD_CUSTOM_VALIDATION_EXCEPTION: myTestString You can look up ExceptionCode';
        List<String> result = CleanFlowErrorMessage.cleanMessage(new List<String>{myTestString});
    }
}