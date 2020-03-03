global class Apex_C1ASExtendedConfig{

webService static void deleteValue(String key, String type) {   
    C1ASCloudConnectorConfig__c u = [SELECT Value__c,Value2__c,Value3__c,Value4__c,Value5__c,Value6__c,Value7__c,Value8__c,Value9__c,Value10__c FROM C1ASCloudConnectorConfig__c WHERE Key__c = :UserInfo.getUserId() and Type__c = :type limit 1];
        
        delete u;
}

//webService static String testClearCustomerSP(String key, String type) {   
//     Datetime cdate = Date.Today();
//        cdate.addHours(-4);
//
//         String CSP = 'CustomerSP';
//
 //       String query = 'SELECT Value__c FROM C1ASCloudConnectorConfig__c WHERE Type__c = \'CustomerSP\' and LastModifiedDate < :cdate';
//        
//          List <sObject> qry = Database.query(query);
//            
//            if ( qry.size() == 0)
//                return 'no results';
//            else
//            return string.valueof(qry.size());
//}

webService static String getValue(String key, String type) {   
    C1ASCloudConnectorConfig__c u = [SELECT Value__c,Value2__c,Value3__c,Value4__c,Value5__c,Value6__c,Value7__c,Value8__c,Value9__c,Value10__c FROM C1ASCloudConnectorConfig__c WHERE Key__c = :UserInfo.getUserId() and Type__c = :type limit 1];
       String rValue = u.Value__c;
        if(u.Value2__c + '' != 'null'){
             rValue = rValue + u.Value2__c;
             if(u.Value3__c + '' != 'null'){
                 rValue = rValue + u.Value3__c;
                 if(u.Value4__c + '' != 'null'){
                     rValue = rValue + u.Value4__c;
                     if(u.Value5__c + '' != 'null'){
                         rValue = rValue + u.Value5__c;
                         if(u.Value6__c + '' != 'null'){
                             rValue = rValue + u.Value6__c;
                             if(u.Value7__c + '' != 'null'){
                                 rValue = rValue + u.Value7__c;
                                 if(u.Value8__c + '' != 'null'){
                                     rValue = rValue + u.Value8__c;
                                     if(u.Value9__c + '' != 'null'){
                                         rValue = rValue + u.Value9__c;
                                         if(u.Value10__c + '' != 'null'){
                                             rValue = rValue + u.Value10__c;
                                         }
                                     }
                                 }
                             }
                         }
                     }
                 }
             }
        }
                return rValue ;
   }
   
webService static String getAllValues(String key) { 
                key = UserInfo.getUserId();  
                String Results = '[';
                String SQL= 'SELECT Key__c,Type__c,Value__c,Value2__c,Value3__c,Value4__c,Value5__c,Value6__c,Value7__c,Value8__c,Value9__c,Value10__c FROM C1ASCloudConnectorConfig__c WHERE Key__c = \'' + key + '\'';
               // return SQL;
                List <sObject> qry = Database.query(SQL);
                Integer count = 0;
                
                if(qry.size() > 0)
                {   
                //return 'here2';
                for (sObject configs: qry)   
                { 
                    C1ASCloudConnectorConfig__c u = (C1ASCloudConnectorConfig__c)configs;
                    String rValue = u.Value__c;
                    if(u.Value2__c + '' != 'null'){
                         rValue = rValue + u.Value2__c;
                         if(u.Value3__c + '' != 'null'){
                             rValue = rValue + u.Value3__c;
                             if(u.Value4__c + '' != 'null'){
                                 rValue = rValue + u.Value4__c;
                                 if(u.Value5__c + '' != 'null'){
                                     rValue = rValue + u.Value5__c;
                                     if(u.Value6__c + '' != 'null'){
                                         rValue = rValue + u.Value6__c;
                                         if(u.Value7__c + '' != 'null'){
                                             rValue = rValue + u.Value7__c;
                                             if(u.Value8__c + '' != 'null'){
                                                 rValue = rValue + u.Value8__c;
                                                 if(u.Value9__c + '' != 'null'){
                                                     rValue = rValue + u.Value9__c;
                                                     if(u.Value10__c + '' != 'null'){
                                                         rValue = rValue + u.Value10__c;
                                                     }
                                                 }
                                             }
                                         }
                                     }
                                 }
                             }
                         }
                    }
                    if(count == 0)
                        Results = Results + '{\"Key\":\"' + u.Key__c + '\",\"Type\":\"' + u.Type__c + '\",\"Value\":\"' + rValue  + '\"}';   
                    else
                        Results = Results + ',{\"Key\":\"' + u.Key__c + '\",\"Type\":\"' + u.Type__c + '\",\"Value\":\"' + rValue  + '\"}';   
                
                    count = count + 1;
                }     

                }  
                Results = Results + ']';
       
                return Results ;
}

webService static String saveValue(String key, String type, String value) {
       key = UserInfo.getUserId();
       String cName = key + type;
       String pValue;
       String value1 = '';
       String value2 = '';
       String value3 = '';
       String value4 = '';
       String value5 = '';
       String value6 = '';
       String value7 = '';
       String value8 = '';
       String value9 = '';
       String value10 = '';
       
      
       double clength = value.length();
       double splitSize = clength/255;
       boolean present = true;
       C1ASCloudConnectorConfig__c temp;
       
       
       try
       {
           temp = [SELECT Value__c,Value2__c,Value3__c,Value4__c,Value5__c,Value6__c,Value7__c,Value8__c,Value9__c,Value10__c FROM C1ASCloudConnectorConfig__c WHERE Key__c = :UserInfo.getUserId() and Type__c = :type limit 1];
       
       }
       catch(Exception e)
       {
            present = false;
       }
       
       //---------------------
       if(splitSize > 0){
           value1 = value;
       }
       if(splitSize > 1){
           value1 = value.substring(0,255);
           value2 = value.substring(255);
       }
       if(splitSize > 2){
           value2 = value.substring(255,510);
           value3 = value.substring(510);
       }
       if(splitSize > 3){
           value3 = value.substring(510,765);
           value4 = value.substring(765);
       }
       if(splitSize > 4){
           value4 = value.substring(765,1020);
           value5 = value.substring(1020);
       }
       if(splitSize > 5){
           value5 = value.substring(1020,1275);
           value6 = value.substring(1275);
       }
       if(splitSize > 6){
           value6 = value.substring(1275,1520);
           value7 = value.substring(1520);
       }
       if(splitSize > 7){
           value7 = value.substring(1530,1785);
           value8 = value.substring(1785);
       }
       if(splitSize > 8){
           value8 = value.substring(1785,2040);
           value9 = value.substring(2040);
       }
       if(splitSize > 9){
           value9 = value.substring(2040,2295);
           value10 = value.substring(2295);
       }
       if(splitSize > 10){
           return 'Insert failed data to large.';
       }
       
       C1ASCloudConnectorConfig__c u = new C1ASCloudConnectorConfig__c(Name = cName, Key__c = UserInfo.getUserId(), Type__c = type, Value__c = value1, Value2__c = value2, Value3__c = value3, Value4__c = value4, Value5__c = value5, Value6__c = value6, Value7__c = value7, Value8__c = value8, Value9__c = value9, Value10__c = value10 );         
       if(present)
          {
              u.Id = temp.ID;
              update u;
          }
          else{
              insert u;
          }
        return 'Success ';
       
       //-----------------

   }
   

}