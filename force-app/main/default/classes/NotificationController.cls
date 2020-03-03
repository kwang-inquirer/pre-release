global class NotificationController {
    
    @AuraEnabled
    public static void updateCallVar() {     
        system.debug('NotificationController: updateCallVar enter.');
    }
    
    @AuraEnabled
    public static String getSessionId() {     
        return UserInfo.getSessionId();
    }
    
    @AuraEnabled
    public static String getUserId() {
        return UserInfo.getUserId();
    }
    
    webService static String pushCTITopic (String params) 
    {
        
        
        try{
            system.debug('pushCTITopic: params: ' + params);
            
            PushTopic pushTopic = new PushTopic();
            pushTopic.Name = UserInfo.getUserId();
            //Server side dont include the where clause to get all agent events
            pushTopic.Query = 'SELECT Id, Name, message__c, user__c FROM ctiMsg__c where user__c = \'' + UserInfo.getUserId() + '\'';
            pushTopic.ApiVersion = 42.0;
            pushTopic.NotifyForOperationCreate = true;
            pushTopic.NotifyForOperationUpdate = true;
            pushTopic.NotifyForOperationUndelete = false;
            pushTopic.NotifyForOperationDelete = false;
            pushTopic.NotifyForFields = 'Referenced';
            insert pushTopic;
            
        }catch(Exception e)
        {
            system.debug('pushCTITopic Exception caught creating push topic:' + e.getMessage());
        }
        
        try{
            ctiMsg__c msg;
            system.debug('pushCTITopic: user: ' + UserInfo.getUserId());
            try{
                
                msg = [SELECT Id, Name, message__c, user__c FROM ctiMsg__c WHERE user__c = :UserInfo.getUserId() LIMIT 1];
                
                system.debug('pushCTITopic record found, update record.');
                DateTime now = DateTime.now();
                
                msg.Name = UserInfo.getUserId() + now;
                system.debug('name: ' + msg.user__c + now);
                msg.message__c = params;
                system.debug('msg: ' + msg.message__c);
                system.debug('Id: ' + msg.Id);
                update msg; //change to update
                
            }catch(Exception e){
                system.debug('pushCTITopic record not found, create new record.' + e.getMessage());
                msg = new ctiMsg__c();
                system.debug('h1');
                if(params.length() > 255)
                	msg.message__c = params.substring(0, 254); //255 charecter limit on field
                else
                    msg.message__c = params;
                system.debug('msg: ' + msg.message__c);
                
                DateTime now = DateTime.now();
                
                msg.Name = UserInfo.getUserId() + now;
                system.debug('name: ' + msg.user__c + now);
                msg.user__c = UserInfo.getUserId();
                system.debug('user: ' + msg.user__c);
                
                insert msg; 
                system.debug('h5');
            }
            
            return UserInfo.getUserId();
        }catch(Exception e)
        {
            system.debug('**pushCTITopic Exception caught:' + e.getMessage());
        }
        
        return 'PushFailed';
        
    }
}