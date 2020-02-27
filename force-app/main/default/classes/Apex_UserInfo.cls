global class Apex_UserInfo{

webService static String getCurrUserSSOInfo() { 
    system.debug('getCurrUserSSOInfo: Enter ');
   
    User u = [SELECT SingleSignOn__c, SSO_AgentId__c,userToken__c, SSO_Extension__c FROM User WHERE Id = :UserInfo.getUserId()];
   	 try{
    	c1as_sso_pwd__c upwd = [SELECT user__c, pwd__c FROM c1as_sso_pwd__c WHERE name = :UserInfo.getUserId()];
        system.debug('getCurrUserSSOInfo: Encrypted PWD' + upwd.pwd__c);
         
        Blob DecodedPWD= EncodingUtil.base64Decode(upwd.pwd__c);
        Blob DecodedKey= EncodingUtil.base64Decode(u.userToken__c);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', DecodedKey, DecodedPWD);
		u.SSO_Pwd__c=decryptedData.toString();
        system.debug('getCurrUserSSOInfo: Decrypted PWD' + decryptedData.toString());
        String JSONString = JSON.serialize(u);
    	system.debug('getCurrUserSSOInfo: Exit ');  
        return JSONString;
    }
    catch(Exception e)
        {
          system.debug('**fwr Exception caught:' + e.getMessage());
     
        }
    return JSON.serialize(u);
   }
   

webService static Void saveCurrUserSSOInfo(String agentId, String pwd, String extension) {
      // User u = new User(); 
   	User u = [SELECT SSO_AgentId__c,userToken__c, SSO_Extension__c FROM User WHERE Id = :UserInfo.getUserId()];  
	system.debug('saveCurrUserSSOInfo: Enter ');
    try{
    	if (u.userToken__c.length()>10 )
       	 	{
    			system.debug('saveCurrUserSSOInfo: there is a saved cryptoKey abort!!! ' + u.userToken__c);
            	return;
        	} 
    	}
    catch(Exception e)
        {
            system.debug('saveCurrUserSSOInfo: cannot find saved cryptoKey continue to get a new cryptoKey. ' );
        }
    
    try{     
        Blob cryptoKey = Crypto.generateAesKey(256);
    	system.debug('saveCurrUserSSOInfo: new generated cryptoKey: ' + EncodingUtil.base64Encode(cryptoKey));
        Blob data = Blob.valueOf(pwd);
		Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKey, data);
	    u.Id = UserInfo.getUserId();
       system.debug('saveCurrUserSSOInfo: getUserId: ' + UserInfo.getUserId());
       u.SSO_AgentId__c = agentId;
       u.userToken__c = EncodingUtil.base64Encode(cryptoKey); 
       u.SSO_Extension__c = extension;
           
        try{
        
        update u; 
        }
        catch(Exception e)
        {
            //insert u;
            system.debug('saveCurrUserSSOInfo: can not update user data');
        }

        try{
       		              
    		c1as_sso_pwd__c currentpassword=new c1as_sso_pwd__c();
    		currentpassword.pwd__c=EncodingUtil.base64Encode(encryptedData);
    		system.debug('saveCurrUserSSOInfo: encryptedData: ' + EncodingUtil.base64Encode(encryptedData));
    		currentpassword.name= UserInfo.getUserId();
    		currentpassword.user__c = UserInfo.getUserId();
        	insert currentpassword;
        }
        catch(Exception e)
        { 
            c1as_sso_pwd__c currentpassword=  [SELECT name, user__c, pwd__c FROM c1as_sso_pwd__c WHERE user__c = :UserInfo.getUserId()]; 
    		currentpassword.pwd__c=EncodingUtil.base64Encode(encryptedData);
            update currentpassword;
            system.debug('saveCurrUserSSOInfo: Trouble saving pwd');
        }
    
    system.debug('saveCurrUserSSOInfo: Exit ');
    }
     catch(Exception e)
        {
          system.debug('**save Exception caught:' + e.getMessage());
        }
   }



}