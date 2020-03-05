public class ContactTriggerHandler {
    private Map<Id, Contact> contacts;
    private Map<Id, Contact> oldContacts;

    public ContactTriggerHandler(Map<Id, Contact> contacts, Map<Id, Contact> oldContacts) {
        this.contacts = contacts;
        this.oldContacts = oldContacts;
    }

    public void runMelissaDataPersonator() {
        try {
            if (!System.isFuture() && !System.isBatch() && contacts.size() == 1) {
                Contact cont = contacts.values()[0];
                if (oldContacts == null || addressFieldsChanged(cont)) {
                    if (!System.Test.isRunningTest()) {
                        MDPERSONATOR.MD_PersonatorWSExt.doOnePersonator((String)cont.Id);
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getMessage() + ' ' + e.getStackTraceString());
        }
    }

    private Boolean addressFieldsChanged(Contact cont) {
        Contact oldContact = oldContacts.get(cont.Id);
        return (cont.MailingStreet != oldContact.MailingStreet) ||
            (cont.MailingCity != oldContact.MailingCity) || 
            (cont.MailingState != oldContact.MailingState) || 
            (cont.MailingPostalCode != oldContact.MailingPostalCode) || 
            (cont.MailingCountry != oldContact.MailingCountry);
    }

}