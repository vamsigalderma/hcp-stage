@isTest
public class ContactTriggertoACC_Test {
	@isTest
    Public static void contactandAccountcreationandupdate_testCreateAccount(){
        
        contact c = new Contact(
        
          FirstName = 'Test',
          LastName = 'Contact',
          Email = 'test@mail.com',
          BrandName__c = 'GainConnect',
          Business_Entity_Name__c = 'Test'
       
        );
        insert c;
        Account getAcc = [select Name from Account];
        system.assertEquals('Test',getAcc.Name);
    }
    @isTest
    Public static void contactandAccountcreationandupdate_testUpdateAccount(){
        List<Account> accList = new List <Account>();
        List<Contact> conList = new List<Contact>();
        Account ac= new Account(
        Name = 'TestCon Con'
        );
        accList.add(ac) ;
        
        Account ac1= new Account(
        Name = 'TestAccount2'
        );
        accList.add(ac1) ;
        
        insert accList; 
        
        contact c1  = new Contact(
          FirstName = 'TestCon',
          LastName = 'Con',
          Email = 'test1@mail.com',
          BrandName__c = 'GainConnect'
          
        );
        conList.add(c1);
        contact c3  = new Contact(
          FirstName = 'TestCon',
          LastName = 'Con',
          Email = 'test1@mail.com',
          BrandName__c = 'GainConnect',
          ClinicName__c = 'TestClinic'
        );
        conList.add(c3);
        
        contact c2  = new Contact(
          FirstName = 'contact',
          LastName = 'test',
          Email = 'contact@mail.com',
          BrandName__c = 'cetaphil',
          ClinicName__c = 'TestAccount2'
        );
         conList.add(c2);
        insert conList;
       
    }
}