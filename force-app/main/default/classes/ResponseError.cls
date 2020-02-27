public with sharing class ResponseError {
	public String Error {get;set;}

	public ResponseError(String error) {
		this.Error = error;
	}
}