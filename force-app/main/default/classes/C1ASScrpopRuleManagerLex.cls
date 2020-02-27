global class C1ASScrpopRuleManagerLex {
    public 	Static String cResults{get;set;}
    //public 	Static String PopType{get;set;}
    //public 	Static String AccountURL{get;set;}
    //public 	Static String CaseURL{get;set;}
    //public 	Static String NURL{get;set;}
    public 	Static String SURL{get;set;}
    public  Static List<Account> AccountResults{get;set;}
    public  Static List<Case> CaseResults{get;set;}
    //public  Static List<RecordType> RecordTypeResults{get;set;}

    

    public Static Integer AccountSize{get;set;}
    //public Static Integer CaseSize{get;set;}
    //public Static Integer RecordTypeSize{get;set;}
    //public Static Integer PC_EngagementProgramSize{get;set;}
    public Static String cParams;
    public Static String Meta_ANI;
    public Static String Meta_DNIS;
    public Static String ANI;
    public Static String DNIS;
    public Static String FANI;
    public Static String FDNIS;
    //public Static String CDN;
    //public Static String PC_EngageProg;
	public Static String NumOfSearch;
    
    public C1ASScrpopRuleManagerLex(){  
    
    }
       public void SecondSearch(){    
        AccountResults = null;
        CaseResults = null;
    	//PopType= null;
     	//AccountURL= null;
    	//CaseURL = null;     
        NumOfSearch='2';
        //DNIS = '0000000000';
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        //cParams=ApexPages.currentPage().
         
        if(params.size() > 0){
        cParams= params.get('params');
        //Meta_ANI=params.get('meta_ani');
        //Meta_DNIS=params.get('meta_dnis'); 
        //cParams='meta_ani='+Meta_ANI+',meta_dnis='+Meta_DNIS;
        //cResults = search(params);    
        }
        system.debug('Here is my parameters' + params.size() + ', ' + cParams);
        //cParams=params;
        //cResults = search(params); 
        if (cParams != null){
         cResults = search(cParams);
        }
    }
 
    public void initSearch(){    
        AccountResults = null;
        CaseResults = null;
    	//PopType= null;
     	//AccountURL= null;
    	//CaseURL = null;    
        NumOfSearch='1';
       
        
        Map<String,String> params = ApexPages.currentPage().getParameters();
        //cParams=ApexPages.currentPage().
        if(params.size() > 0){
        cParams= params.get('params');
        //Meta_ANI=params.get('meta_ani');
        //Meta_DNIS=params.get('meta_dnis'); 
        //cParams='meta_ani='+Meta_ANI+',meta_dnis='+Meta_DNIS;
        //cResults = search(params);    
        }
        system.debug('Here is my parameters' + params.size() + cParams);
        //cParams=params;
        //cResults = search(params); 
        if (cParams != null){
         cResults = search(cParams);
        }
    }
    
    static Boolean isEmpty (List <List <sObject>> oList) {
        if ( oList.size() == 0 ) return true;
        Boolean empty = true;
        for ( List<sObject> subList : oList ) {
            if ( subList.size() > 0 ) {
                empty = false;
            }
        }
        return empty;
    }
    
        static String doSQL(String SQL) {
        // SOSL: 'FIND \'1001\' IN PHONE FIELDS RETURNING Account(ID, Name), Contact(ID, Name)'
        if ( SQL.toUpperCase().startsWith('FIND') ) {
            // serializes into an array of arrays of JSON [[JSON1],[JSON2],...]
            List <List <sObject>> qry = search.query(SQL);
            
            if ( isEmpty(qry) ) {
                return null;
            }
            
            for (List<sObject> param : qry) {
            
               setResults(param); 
            }   
             
             
            return JSON.serialize(qry);  
            
        }
        // SOQL: Select ....
        else {
            // serializes into an array of json: [<JSON>]
            List <sObject> qry = Database.query(SQL);
            
            if ( qry.size() == 0){
                //PopType='NoAcctMatch';
                 //SURL='/lightning/cmp/c__AG_PC_Enrollment_Patient_Lookup?c__phonenumber=' + ANI;
                 //SURL=NURL;
                //if(NumOfSearch!='2'){
                //        notificationController.pushCTITopic(SURL);
                //    }
                // system.debug('ScreenPop Type is ' + SURL );
                //stevie check apepages before using or move elsewhere, UI calls will not have a page refrence.
                 //ApexPages.currentPage().getParameters().put('nurl', NURL); 
                 //ApexPages.currentPage().getParameters().put('poptype',PopType); 
                 system.debug('ScreenPop Type is No Match' );
                 return null;
            }
                //return null;
                
            setResults(qry); 
            
            return JSON.serialize(qry);
        }
    }
    
    
       
    static void setResults(List <sObject> qry) {
      
            SObjectType sObjectType = qry.getSObjectType();
            
            if(sObjectType == Account.sObjectType)
            {
                 AccountResults= ((List<Account>)qry);
                 AccountSize = AccountResults.size();
                system.debug('Account Size is '+ AccountSize );
                
                if(AccountSize <1)
                {
                    return;
                // AccountResults = null;
                // PopType='NoAcctMatch';
                // NURL='/lightning/cmp/c__AG_PC_Enrollment_Patient_Lookup';
                // SURL=NURL;
                // system.debug('ScreenPop Type is '+ PopType + NURL );
                 //system.debug('ScreenPop Type is No Match' );
                }
                if (AccountSize > 1) {
                    //PopType='MultiAcctMatch';
                    SURL='/apex/C1ASAdvScrPopClientLex?params=meta_ani='+ ANI;
                    //isMultiMatch='true';
                    
                    system.debug('ScreenPop Type is Multiple Accounts Match with number of accounts='+ AccountSize );
                }
                else {
                  Account SingleAcct = AccountResults.get(0);
                  String AcctRecordTypeId;
            	  //PopType='SingleAcct';
                  SURL='/lightning/r/Account/'+ SingleAcct.Id +'/view';

                    
                  //SURL=AccountURL;
                  system.debug('Matched Acct with Id as: ' + SingleAcct.Id + '  Account URL is:  '+ SURL);
                 

            	}
                if(NumOfSearch!='2'){
                        notificationController.pushCTITopic(SURL);
                    }
            }                  
            
            
            
            
             
    }
     
     
  
 	static String santizeInputValues(String inName, String inValue) {
      String outValue = inValue;
    
     // do custom code here....
     if (inName == '${meta_ani}') {
 //        if (isEmpty(inValue))  {
                // do nothing... return inValue back..
 //        } else 
         if (inValue.trim().startsWith('+1')){       
                  outValue = inValue.substring(2);        
         } else if (inValue.trim().startsWith('+')){       
                  outValue = inValue.substring(1); 
         } else{
            
             if (outValue.length()==10) {
             FANI='('+ outValue.mid(0,3)+') '+outValue.mid(3,3)+'-'+outValue.mid(6,4);
             
             outValue=FANI;
             system.debug('meta_ani is formated as: ' + outValue);
             }
             ANI= inValue;
             system.debug('ANI is sanitized as: ' + ANI);
         }
     }
        Else if(inName == '${meta_dnis}'){
            if (inValue.trim().startsWith('1')){       
                  outValue = inValue.substring(1);
                DNIS=outValue;
                system.debug('meta_dnis is sanitized as: ' + DNIS);
            } else{
                DNIS=inValue;
            }
        }
     //Else if(inName == '${CDN}'){
    //
//                outValue = inValue;
//                CDN=outValue;
 //               system.debug('CDN is sanitized as: ' + CDN);
           
 //       }
        
  
     return outValue;
     }
        /**
     * Search using a param sequence
     * @param params: var1=val1,var2=val2,...
     */
    webService static String search (String params) 
    {
        system.debug('search params: ' + params);
        
        // TODO: fetch SQL from some SF table
        String[] SQL = new String[2];
        String flagOriginal = 'false';
        
         //SQL[0] = 'FIND \'${meta_original_ani}\' IN PHONE FIELDS RETURNING Account(ID, Name, RecordTypeID)';
         //SQL[1] = 'FIND \'${meta_ani}\' IN PHONE FIELDS RETURNING Account(ID, Name, RecordTypeID)';
         //SQL[1] = 'FIND 1234567890 IN PHONE FIELDS RETURNING Account(ID, Name, RecordTypeID)';
           //for test case coverage
         //SQL[2] = 'Select Id, Name, RecordTypeId from Account where Home_Phone__c=1234567890 or Work_Phone__c=1234567890 or Mobile_Phone__c=1234567890';
         
         SQL[0] = 'Select Id, Name, Phone from Account where Phone=\'${meta_ani}\' or Phone=:ANI';
         SQL[1] = 'Select Id, Name, Phone from Account where Phone=\'${meta_original_ani}\' or Phone=:ANI';
              
       
                 
        // extract params: var1=val,va2=val2,...
        List<String> oParams = params.split(',', 0);
        
        for (String param : oParams ) {
            String[] keyVal = param.split('=', -1);
            
            
            
            if ( keyVal.size() != 2 ) 
                continue;
                
            String varName   = '${' + keyVal[0] + '}';  // var name ${ani}, ${status},...
            String varVal    = keyVal[1];
            //system.debug('**testMethod  run1:var Name:Value 1' + varName + ':' + varVal);
            //Sanitize input values before replacing
            varVal = santizeInputValues(varName, varVal);
            //if (varName == '${DNIS}'){
                //DNIS=varVal;
            //}                            
            // replace
           	for (Integer i = 0 ; i < SQL.size() ; i++ ) {
                system.debug('**testMethod  run1:var Name: before replacement ' + SQL[i]);
                SQL[i] = SQL[i].replace(varName, varVal);
                system.debug('**testMethod  run1:var Name: After replacement ' + SQL[i]);
                //system.debug('**testMethod  run1:var Name:Value 2' + varName + ':' + varVal);
                
          	}

        }
        
        /* debug? 
        if ( params.contains('debug=true')) {
            return JSON.serialize(SQL);
        }*/
        
       
        // execute SOQL
        for (String stmt : SQL ) {
            String json = doSQL(stmt);
            if ( json != null ) {
                return json;
            }
        }
        
        
        
        //DEBUG: will return the SQL list if no results are found
        return JSON.serialize(SQL);
    }

    

}