public with sharing class PianoClient {
	private Piano_Api_Setting__mdt settings; 

	public PianoClient() {
		Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
		String settingsName = isSandbox ? 'dev' : 'prod';
		settings = [SELECT Id, Term_Id__c, Term_Name__c, Base_URI__c FROM Piano_Api_Setting__mdt WHERE DeveloperName = :settingsName];
	}

	public Map<String, Object> callPiano(String trackingId) {
		String pianoParams = 'term_id=' + settings.Term_Id__c + '&term_name=' + settings.Term_Name__c + '&tracking_id=' + EncodingUtil.urlEncode(trackingId, 'UTF-8');
		HttpRequest req = new HttpRequest();
		req.setEndpoint(settings.Base_URI__c);
		req.setMethod('POST');
		req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
		req.setBody(pianoParams);
		HttpResponse res = new Http().send(req);
		return (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
	}
}