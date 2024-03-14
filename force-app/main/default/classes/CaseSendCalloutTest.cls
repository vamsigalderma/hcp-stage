@isTest
public class CaseSendCalloutTest {
   public testmethod static void makeCalloutTest()  {
        Contact c = new Contact(LastName = 'Zemancik', CIAMId__c = 'CiamId12345', TrustLevel__c = 'Blocked', MailingCountry = 'Brazil',
            BrandName__c = 'GainConnect', Email = 'miroslav.zemancik@emea.merkleinc.com', Specialty__c = 'Allergy and Immunology', Profession__c = 'Doctor',
            Gender__c = 'male');
        insert c;
        
       Case caseObj = new Case(
            ContactId = c.id,
            Status = 'Working',
            Origin = 'Phone');

        insert caseObj;
        caseObj = [select id, casenumber from case where id = : caseObj.id];
    
   
        List<Case> cs = new List<Case>();
        cs.add(caseObj);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        CaseSendCallout.makeCallout(cs);
    }
    }