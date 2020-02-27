public with sharing class PianoController {
    @AuraEnabled
    public static void callPiano(String pianoId){
        try {
            Map<String, Object> res = new PianoClient().callPiano(pianoId);
            if ((Integer)res.get('code') != 0) {
                throw new GenericException('Failed to call piano api: ' + (String)res.get('message'));
            }
        }
        catch (Exception e) {
            throw new GenericException('Failed to call piano api: ' + e.getMessage());
        }
    }
}