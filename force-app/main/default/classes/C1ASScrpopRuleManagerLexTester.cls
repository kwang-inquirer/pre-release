@isTest() 
public class C1ASScrpopRuleManagerLexTester  {
private static testMethod void testSearch() {
        system.debug('**testMethod Start test');
        // ANI to search on
        string ActiveDnis = '2222';
        string inActiveDnis = '3333';
       string aMatch = '1234567890';
        string lMatch = '555666';
        string cMatch = '666777';
        string alMatch = '1234567899';
        string acMatch = '888999';
        string alcMatch = '111222';
    	string recordtypeid1='012m00000000qB9AAI';
   		string recordtypeid2='012m00000000qB9AAI';
        try {
  
            
            //-------------- S1 string aMatch = '444555';
            //create Account
            Account aAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            aAccount.Phone = aMatch;
            //aAccount.Work_Phone__c = aMatch;
            aAccount.Name = 'test';
            //aAccount.RecordTypeId=recordtypeid1;
            insert aAccount;
            String aAccountId = aAccount.Id;
            system.debug('**createAccount  Id=' + aAccountId);
            
            Account atempAccount = [SELECT ID FROM Account WHERE Id = :aAccountId];
            if(atempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo atempAccount = null');
            
            }
            system.debug('*********IsItATaskWithInfo 1');
           
             //PatientConnect__PC_Engagement_Program__c aPCEngage = new 	PatientConnect__PC_Engagement_Program__c();           	    		
             //aPCEngage.Reference_DNIS__c='8001234567';
             //aPCEngage.PatientConnect__PC_Program_Code__c='REPATHA';
           	 //aPCEngage.Name ='Repatha®';
		     //insert aPCEngage; 
		     //String PCEngageId = aPCEngage.Id;
         
            //Case aCase = new Case();
            //aCase.Type ='Program' ;
            //aCase.AccountId = aAccountId;
            //aCase.PatientConnect__PC_Engagement_Program__c = PCEngageId;
            //aCase.RecordTypeId=aRecordTypeId;
            //insert aCase;
            //String aCaseId = aCase.Id;
            
       
            //--------------S2 string alMatch = '777888';
            //create Account
            Account alAccount = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            alAccount.Phone = alMatch;
            //alAccount.Work_Phone__c = alMatch;
            alAccount.Name = 'test';
            //alAccount.RecordTypeId=recordtypeid1;
            insert alAccount;
            String alAccountId = alAccount.Id;
            system.debug('**createAccount  Id=' + alAccountId);
            
            Account altempAccount = [SELECT ID FROM Account WHERE Id = :alAccountId];
            if(altempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo altempAccount = null');
            
            }
            
            //create Account
            Account al2Account = new Account();
            //tAccount.FirstName = 'test';
            //tAccount.LastName = 'test';
            al2Account.Phone = alMatch;
            al2Account.Name = 'test';
            insert al2Account;
            String al2AccountId = al2Account.Id;
            system.debug('**createAccount  Id=' + al2AccountId);
            
            Account al2tempAccount = [SELECT ID FROM Account WHERE Id = :al2AccountId];
            if(altempAccount == null)
            {
                system.debug('*********IsItATaskWithInfo al2tempAccount = null');
            
            }
            
     
       
   
          
            
           
            
            
            
            //---------------------------------------------------------------------
            
          
           
            
             //PageReference pageRef = Page.AdvancedScreenPopClient;
            PageReference pageRef = Page.C1ASAdvScrPopClientLex; 
            Test.setCurrentPage(pageRef);

            //ApexPages.currentPage().getParameters().put('params', 'meta_original_ani=' + alcMatch);
            ApexPages.currentPage().getParameters().put('params', 'meta_ani=1234567890,meta_dnis=18001234567');
            
            C1ASScrpopRuleManagerLex controller = new C1ASScrpopRuleManagerLex();
            controller.initSearch();
            controller.SecondSearch();
            ApexPages.currentPage().getParameters().put('params', 'meta_ani=1234567899,meta_dnis=8001234567');
            
            //C1ASScrpopRuleManagerLex controller = new C1ASScrpopRuleManagerLex();
            controller.initSearch();
            controller.SecondSearch();
             ApexPages.currentPage().getParameters().put('params', 'meta_ani=9999999999');
            
            //C1ASScrpopRuleManagerLex controller = new C1ASScrpopRuleManagerLex();
            //controller.santizeInputValues( '${meta_ani}', '+1234098567');
            controller.initSearch();
            controller.SecondSearch();  
            //controller.santizeInputValues( '${meta_ani}', '+1234098567');
               
            //Id [] fixedSearchResults;
      
            //fixedSearchResults = new Id[]{aAccountId,CampaignId};
            //fixedSearchResults = new Id[]{aAccountId};
            //Test.setFixedSearchResults(fixedSearchResults);
            //String run1 = AmgenUBCCustomScreenPop.search('params=meta_ani=' + aMatch);
            //String run1 = AmgenUBCCustomScreenPop.search('params=meta_ani=1234567890');
            //system.debug('**testMethod  run1:' + run1);
            //system.debug('**testMethod  AccountListSize: '+ AmgenUBCCustomScreenPop.AccountSize);
            
           
            
            
   

        } 
        catch(Exception e)
        {
          system.debug('**testMethod Exception caught:' + e.getMessage());
        }
        finally {

        }
    }
}