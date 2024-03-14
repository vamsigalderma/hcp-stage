/***************************************************************************************************
 * Name          : CaseSendCallout
 * Description   : Class to handle invocable method to run API call to another SF instance
 * Date          : 09/09/2022
 * Author        : Vladislav Rakita
 ***************************************************************************************************/
global class CaseSendCallout {
    @InvocableMethod(label='Make api call to another SF Org')
    public static List<String> makeCallout(List<Case> cases) {
        List<String> result = new List<String>();
        List<Id> cIds = new List<Id>();
        for (Case c : cases) {
            cIds.add(c.Id);
        }
        makeCalloutFuture(cIds);
        return result;
    }

    @future(callout=true)
        public static void makeCalloutFuture(List<Id> cIds) {
        String caseId = cIds[0]; // Retrieve the first element of the list
        Case c = [SELECT Id, ContactId FROM Case WHERE Id = :caseId][0];
        if (c.contactId != null)  {
            
            Contact cc = [SELECT Id, FirstName, LastName, Email, Phone, CIAMId__c, NPIId__c, CPF__c, Birthdate, Gender__c,
                              Profession__c, Specialty__c
                          FROM Contact
                          WHERE Id = :c.contactId];
            Map<String, String> request = new Map<String, String>();
            String gender = '';
            if (cc.Gender__c != null) {
                if (cc.Gender__c.toLowerCase() == 'female') {
                    gender = 'F';
                } else if (cc.Gender__c.toLowerCase() == 'male') {
                    gender = 'M';
                }
            } else {
                gender = 'N/A';
            }
            request.put('FirstName__c', cc.FirstName);
            request.put('LastName__c', cc.LastName);
            request.put('EmailGCP__c', cc.Email);
            request.put('CelularGCP__c', cc.Phone);
            request.put('CPF__c', cc.CPF__c);
            request.put('CRM_UF__c', cc.NPIId__c);
            request.put('PersonBirthdate__c', String.valueOf(cc.Birthdate));
            request.put('Gender_vod__c', gender);
            
            List<String> engSpecialty = new List<String> {
            'Allergy and Immunology','Anesthesiology','Cardiology','Cardiovascular Surgery','General Surgery','Pediatric Surgery','Plastic Surgery','Resident Plastic Surgery','Thoracic Surgery','Medical Clinic','Coloproctology','Dermatologist','Resident Dermatologist','Endocrinology and Metabology','Gastroenterology','Medical Genetics','Geriatrics','Gynecology and Obstetrics','Aesthetic Medicine','Physical Medicine and Rehabilitation','Intensive Care Medicine','Nephrology','Neurology','Nutrology','Ophthalmology','Orthopedics and Traumatology','Otorhinolaryngology','Others','Pathology','Paediatrics','Pulomonology','Psychiatry','Radiology and Diagnostic Imaging','Radiotherapy','Infectology','Occupational Medicine','Dentist','Pharmacist','Biomedical Scientist','Nurse'
            };
            List<String> engProfession = new List<String> {
                'Doctor', 'Dentist', 'Pharmacist', 'Biomedical Scientist', 'Nurse'
            };
            List<String> ptProfession = new List<String> {
                'Médico', 'Dentista', 'Farmacêutico', 'Biomedicina', 'Enfermeiro'
            };
            List<String> ptSpecialty = new List<String>  {
                'ALERGIA E IMUNOLOGIA','ANESTESIOLOGIA','CARDIOLOGIA','CIRURGIA CARDIOVASCULAR','CIRURGIA GERAL','CIRURGIA PEDIÁTRICA','CIRURGIA PLÁSTICA','CIRURGIA PLÁSTICA RESIDENTE','CIRURGIA TORÁCICA','CLINICA MÉDICA','COLOPROCTOLOGIA','DERMATOLOGISTA','DERMATOLOGISTA RESIDENTE','ENDOCRINOLOGIA E METABOLOGIA','GASTROENTEROLOGIA','GENÉTICA MÉDICA','GERIATRIA','GINECOLOGIA E OBSTETRÍCIA','MEDICINA ESTÉTICA','MEDICINA FÍSICA E REABILITACAO','MEDICINA INTENSIVA','NEFROLOGIA','NEUROLOGIA','NUTROLOGIA','OFTALMOLOGIA','ORTOPEDIA E TRAUMATOLOGIA','OTORRINOLARINGOLOGIA','OUTROS','PATOLOGIA','PEDIATRIA','PNEUMOLOGIA','PSIQUIATRIA','RADIOLOGIA E DIAGNÓSTICO POR IMAGEM','RADIOTERAPIA','INFECTOLOGIA','MEDICINA DO TRABALHO','Dentista','Farmaceutico','Biomédico','Enfermeiro'
            };
            string VeevaRecordType =  System.Label.VeevaRecordType;
            Integer i, j = 0;
            String specialtyTranslated = '';
            String translatedProfession = '';
            
           //if(cc.Specialty__c!=null){
               i = engSpecialty.indexOf(cc.Specialty__c);
            //}
            //if(cc.Profession__c!=null){
               j = engProfession.indexOf(cc.Profession__c);
            //}
            //
           // if(i>=0 && j>=0){
            specialtyTranslated = ptSpecialty.get(i);
            translatedProfession = ptProfession.get(j);
            
            request.put('Account_Category__c', translatedProfession.toUpperCase());
            request.put('Specialty_1_vod__c', specialtyTranslated.toUpperCase());
            request.put('RecordTypeId', VeevaRecordType);
            request.put('IdCaseGCP__c', caseId);
            
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint('callout:Veeva1/services/data/v54.0/sobjects/ValidacaoMesclagem__c/IdCIAMGCP__c/' + cc.CIAMId__c);
            req.setMethod('PATCH');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(request));
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            
           System.debug('****res***'+res.getBody());
           // Parse the JSON response and retrieve the "Id" value
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201 ){          
              Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());                 

                String veevaId = (String) responseMap.get('id');
                Case nCase = new Case(Id = caseId, Request_Description__c = 'Req. body: ' + res.getBody() + '; Status Code:'
                    + res.getStatusCode(), VeevaValidationId__c = veevaId);
                update nCase;
                system.debug('veevaId+++++'+veevaId);
                
                
            }
       // }
        }
    }
}