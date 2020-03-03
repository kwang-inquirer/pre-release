public class CleanFlowErrorMessage  {
    @InvocableMethod
	public static List<String> cleanMessage(List<String> ErrorGiven){
		List<String> strResult = new List<String>();
		for(string thisError: ErrorGiven){
			System.debug('This error: ' + thisError);
			String thisResult = '';
			if(thisError.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION:')) {
				thisResult = thisError.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION:', 'You can look up ExceptionCode');
			}
            else{
                thisResult = thisError;
            }
			strResult.add(thisResult);
		}
		return strResult;
	}
}