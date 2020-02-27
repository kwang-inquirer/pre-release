global class EmailHistoryTracker {
  
  public static boolean debug = Label.PMN_DEBUG== 'true'?true:false;
  @InvocableMethod(label='Email Alerts with Activity History')
   public static void SendEmailsToLeadsContacts(List<EmailInput> LstEmailInput) 
   {
       List<Messaging.SingleEmailMessage> LstSEM = new List<Messaging.SingleEmailMessage>();

       Set<String> conOrLeadIds = new Set<String>();
       Set<String> verifiedIds = new Set<String>();

       Set<String> developerNames = new Set<String>();
       List<EmailTemplate> emailTemplates = new List<EmailTemplate>();
       Map<String, EmailTemplate> emailTemplatesMap = new Map<String, EmailTemplate>();

       Set<String> fromAddresses = new Set<String>();
       List<OrgWideEmailAddress> orgWideEmailAddresses = new List<OrgWideEmailAddress>();
       Map<String, OrgWideEmailAddress> orgWideEmailAddressesMap = new Map<String, OrgWideEmailAddress>();

       for (EmailInput ei:LstEmailInput)
       {
          conOrLeadIds.add(ei.ConOrLeadId);
          developerNames.add(ei.emailTemplateName);
          fromAddresses.add(ei.FromEmailAddress);
       }

       if (!conOrLeadIds.isEmpty())
       {
          for (User usr : [SELECT Id, Email FROM User WHERE Id IN :conOrLeadIds])
          {
            if (usr.Email != null)
            {
              verifiedIds.add(usr.Id);
            }
          }

          for (Contact cont : [SELECT Id, Email FROM Contact WHERE Id IN :conOrLeadIds])
          {
            if (cont.Email != null)
            {
              verifiedIds.add(cont.Id);
            }
          }

          for (Lead ld : [SELECT Id, Email FROM Lead WHERE Id IN :conOrLeadIds])
          {
            if (ld.Email != null)
            {
              verifiedIds.add(ld.Id);
            }
          }
       }

       if (!developerNames.isEmpty())
       {
          emailTemplates.addAll([SELECT 
              Id, 
              DeveloperName 
            FROM 
              EmailTemplate 
            WHERE 
              DeveloperName IN :developerNames]);

          if (!emailTemplates.isEmpty())
          {
            for (EmailTemplate et : emailTemplates)
            {
              emailTemplatesMap.put(et.DeveloperName, et);
            }
          }
       }
       
       if (!fromAddresses.isEmpty())
       {
          orgWideEmailAddresses.addAll([SELECT 
              Id,
              Address 
            FROM 
              OrgWideEmailAddress 
            WHERE Address IN :fromAddresses]);

          if (!orgWideEmailAddresses.isEmpty())
          {
            for (OrgWideEmailAddress owea : orgWideEmailAddresses)
            {
              orgWideEmailAddressesMap.put(owea.Address, owea);
            }
          }
       }

       for (EmailInput ei:LstEmailInput)
       {
                if(debug)System.debug('@Passed Id:::' + ei.RecordId);
                if(debug)System.debug('@Passed Id:::' + ei.ConOrLeadId);
                if(debug)System.debug('@FromEmailAddress=' + ei.FromEmailAddress);
                if(debug)System.debug('@additional_recipient1=' + ei.additional_recipient1);
                if(debug)System.debug('@additional_recipient2=' + ei.additional_recipient2);
                if(debug)System.debug('@additional_recipient3=' + ei.additional_recipient3);
                if(debug)System.debug('@additional_recipient4=' + ei.additional_recipient4);
                if(debug)System.debug('@additional_recipient5=' + ei.additional_recipient5);

                String RecPrefix = String.valueOf(ei.ConOrLeadId).substring(0,3);

                if(debug)System.debug('PrefixId:' + RecPrefix);                
                
                //boolean ObjEmailExist = ObjectEmailIdExist(RecPrefix, ei.ConOrLeadId);
                boolean ObjEmailExist = verifiedIds.contains(ei.ConOrLeadId);
                
                 if (ei.ConOrLeadId != null && ObjEmailExist)
                 {
                        Id TemplateId = null;

                        EmailTemplate et = emailTemplatesMap.get(ei.emailTemplateName);
                        
                        if (et != null) 
                        {
                          TemplateId = et.id;
                        }
                        
                        if (debug)System.debug('@TemplateId:' + TemplateId ); 

                        Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
                        mailMsg.setTemplateId(TemplateId);
                        mailMsg.setTargetObjectId(ei.ConOrLeadId);
                        mailMsg.setTreatTargetObjectAsRecipient(true);
                        mailMsg.setWhatId(ei.RecordId);
                        
                        List<String> LstEmail = getAdditionalAddresses(new List<String>{ei.additional_recipient1,ei.additional_recipient2,ei.additional_recipient3,ei.additional_recipient4,ei.additional_recipient5});
                        
                        if (LstEmail.size() > 0) 
                        {
                           MailMsg.setCcAddresses(LstEmail);
                        }
                        
                        if (ei.FromEmailAddress != null)
                        {
                            OrgWideEmailAddress owea = orgWideEmailAddressesMap.get(ei.FromEmailAddress);

                            if (owea != null) 
                            {
                                mailMsg.setOrgWideEmailAddressId(owea.Id);
                            }
                        }

                        LstSEM.add(mailMsg);
                }
         }

        if (!Test.isRunningTest())
        {
            Messaging.sendEmail(LstSEM,true);
        }
  }
  
  public static List<String> getAdditionalAddresses(List<String> emails){
    List<String> LstEmail= new List<String>();
    for(String em:emails){
      if(em != null && ValidEmail(em)){
         LstEmail.add(em);
      }
    }
    return LstEmail;
  }
  
  /*
  public static Boolean ObjectEmailIdExist(String RecPrefix,Id ObjId){
      boolean ObjEmailExist = false;
    if(RecPrefix.equalsIgnoreCase('00Q') || RecPrefix.equalsIgnoreCase('003')|| RecPrefix.equalsIgnoreCase('005')){
       
       if(RecPrefix.equalsIgnoreCase('003')){
         List<Contact> LstCon = [select email from contact where id=:ObjId];
         if(LstCon.size()>0 && LstCon[0].email != null) ObjEmailExist = true;
       }
       else if(RecPrefix.equalsIgnoreCase('005')){
         List<User> LstUser = [select email from User where id=:ObjId];
         if(LstUser.size()>0 && LstUser[0].email != null) ObjEmailExist = true;                          
       }
       else if(RecPrefix.equalsIgnoreCase('00Q')){
         List<Lead> LstLead=[select  email from Lead where id=:ObjId];
         if(LstLead.size()>0 && LstLead[0].email != null) ObjEmailExist = true;
       }
       
    }
    return ObjEmailExist;
  }
  */
  public static Boolean ValidEmail(String email) {
    Boolean validEmail= true;
    String regEx= '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
    Pattern patt= Pattern.compile(regEx);
    Matcher match= patt.matcher(email);
    if (!match.matches()) 
        validEmail= false;
    return validEmail; 
    }
  public class EmailInput{
        @InvocableVariable(label='From Email Address' description='An Org-Wide Email Address, or leave blank to use the executing User\'s Email Address' required=true) 
        public String FromEmailAddress;
        @InvocableVariable(label='Contact Id or Lead Id' description='Record Id that the Email Alert is to be attached to.' required=true) 
        public Id ConOrLeadId;   
        @InvocableVariable(label='RecordId' description='The Record Id of the current record' required=true) 
        public Id RecordId;  
        @InvocableVariable(label='Email Template Unique Name' description='Email Template Unique Name' required=true) 
        public String emailTemplateName;
        @InvocableVariable(label='Additional Recipient 1' description='An Additional Recipient\'s Email Address' required=false) 
        public String additional_recipient1;  
        @InvocableVariable(label='Additional Recipient 2' description='An Additional Recipient\'s Email Address' required=false) 
        public String additional_recipient2;  
        @InvocableVariable(label='Additional Recipient 3' description='An Additional Recipient\'s Email Address' required=false) 
        public String additional_recipient3;  
        @InvocableVariable(label='Additional Recipient 4' description='An Additional Recipient\'s Email Address' required=false) 
        public String additional_recipient4;  
        @InvocableVariable(label='Additional Recipient 5' description='An Additional Recipient\'s Email Address' required=false) 
        public String additional_recipient5;                                      
  }
}