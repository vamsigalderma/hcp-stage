import { LightningElement, api,track } from 'lwc';
//Import Apex Methods
import getPicklistValuesContact from "@salesforce/apex/HCPUSerRegistrationController.getPicklistValues";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import submitRegistrationBrazil from '@salesforce/apex/HCPUSerRegistrationController.submitRegistrationBrazil';
import uploadFile from '@salesforce/apex/HCPUSerRegistrationController.uploadFile';
import { deleteRecord } from "lightning/uiRecordApi";
import LightningAlert from 'lightning/alert';
const MAX_FILE_SIZE = 10485760;
//Error Messages
import HCP_VALUE_MISSING from '@salesforce/label/c.HCPValueMissing';
import HCP_EMAIL_EXISTS from '@salesforce/label/c.HCPEmailAddressExists';
import HCP_EMAIL_INVALID from '@salesforce/label/c.HCPEmailAddressInvalid';
import HCP_INVALID_MEDICAL_ID from '@salesforce/label/c.HCPInvalidMedicalId';
import HCP_INVALID_PHONE from '@salesforce/label/c.HCPInvalidPhone';
import HCP_INVALID_ZIP from '@salesforce/label/c.HCPInvalidZip';
import HCP_INVALID_CPF from '@salesforce/label/c.HCPInvalidCPF';
//Form Field Labels
import HCP_TITLE from '@salesforce/label/c.HCPTitle';
import HCP_FIRST_NAME from '@salesforce/label/c.HCPFirstName';
import HCP_LAST_NAME from '@salesforce/label/c.HCPLastName';
import HCP_EMAIL from '@salesforce/label/c.HCPEmailAddress';
import HCP_PROFESSION from '@salesforce/label/c.HCPProfession';
import HCP_MEDICAL_ID from '@salesforce/label/c.HCPMedicalId';
import HCP_ORG_NAME from '@salesforce/label/c.HCPOrgName';
import HCP_PHONE from '@salesforce/label/c.HCPPhoneNumber';
import HCP_Address from '@salesforce/label/c.HCPAddress';
import HCP_STATE from '@salesforce/label/c.HCPState';
import HCP_CITY from '@salesforce/label/c.HCPCity';
import HCP_GENDER from '@salesforce/label/c.HCPGender';
import HCP_ZIP_CODE from '@salesforce/label/c.HCPZipCode';
import HCP_REGISTER_LABEL from '@salesforce/label/c.HCPRegisterLabel';
import HCP_LEGAL_NOTOCE from '@salesforce/label/c.HCPLegalNotice';
import HCP_CONSENT_EMAIL from '@salesforce/label/c.HCPConsentEmail';
import HCP_LICENSE_AGREEMENT from '@salesforce/label/c.HCPLicenseAgreementUrl';
import HCP_PRIVACY_NOTICE from '@salesforce/label/c.HCPPrivacyNotice';
import HCP_COUNTRY_LOGIN_URL from '@salesforce/label/c.HCpCountryLoginUrl';
import HCP_SUCCESS_URL from '@salesforce/label/c.hcpSuccessUrl';
import HCP_DOB from '@salesforce/label/c.HCPDateOfBirth';
import HCP_CPF from '@salesforce/label/c.HCPCpf'; 
import HCP_COUNCIL_STATE from '@salesforce/label/c.HCPCouncilState';
import HCP_SPECIALTY from '@salesforce/label/c.HCPSpecialty';
//
import HCP_CONFIRM_EMAIL_NO_MATCH from '@salesforce/label/c.HCPConfirmEmailNoMatch';
import HCP_CONFIRM_EMAIL from '@salesforce/label/c.HCPConfirmEmailAddress';


import {validateEmailAddressFunc, submitRegistrationUtility, validateCheckboxUtility, 
    getLabels, validatePassword, confirmPasswordValidation, confirmEmailValidation} from 'c/lwcHcpJsUtility';

export default class LwcHcpUserRegistrationBrazil extends LightningElement {
    
    //urls
    hcpLeagalNotice = HCP_LEGAL_NOTOCE;
    hcpConsentEmail = 'mailto:' + HCP_CONSENT_EMAIL + '?subject=';
    hcpLicenseAfreement = HCP_LICENSE_AGREEMENT;
    hcpPrivacyNotice = HCP_PRIVACY_NOTICE;
    hcpLoginUrl = HCP_COUNTRY_LOGIN_URL;
    hcpSuccessUrl = HCP_SUCCESS_URL;
    //error messages (Translated based on the Site's default language)
    hcpValueMissing = HCP_VALUE_MISSING;
    hcpEmailExists = HCP_EMAIL_EXISTS;
    hcpEmailInvalid = HCP_EMAIL_INVALID;
    hcpInvalidMedicalId = HCP_INVALID_MEDICAL_ID;
    hcpInvalidPhone = HCP_INVALID_PHONE;
    hcpInvalidZip = HCP_INVALID_ZIP;
    hcpInvalidCPF = HCP_INVALID_CPF;
    //field labels - translated values from the custom labels
    hcpTitle = HCP_TITLE;
    hcpFirstName = HCP_FIRST_NAME;
    hcpLastName = HCP_LAST_NAME;
    hcpEmailAddress = HCP_EMAIL;
    hcpProfession = HCP_PROFESSION;
    hcpMedicalId = HCP_MEDICAL_ID;
    hcpOrgName = HCP_ORG_NAME;
    hcpPhoneNumber = HCP_PHONE;
    hcpAddress = HCP_Address;
    hcpState = HCP_STATE;
    hcpCity = HCP_CITY;
    hcpGender = HCP_GENDER;
    hcpZipCode = HCP_ZIP_CODE;
    hcpRegisterLabel = HCP_REGISTER_LABEL;
    hcpDateOfBirth = HCP_DOB;
    hcpCPF = HCP_CPF;
    hcpCouncilState = HCP_COUNCIL_STATE;
    hcpSpecialty = HCP_SPECIALTY;
        //Combo Box Options
    comboBoxOptions = {};

    inputFieldValuesWrapper = {};

    
    @api recordId;
    @api objectApiName;
    @api instructionsArrayText;
    isDoctor;
    
    isLoading;
    largeScreen;
    smallScreen;
    showContent;
    councilStateDefaultvalue = '';
    professionDefaultvalue = 'Doctor';
    specialityDefaultvalue = 'Aesthetic Medicine';
    resultMap = [];
    @api contactRecordId;
    frontfileData;
    backfileData;
    @track name;
    @track specialityOptions = [];
    @track value;
    frontFileSize;
    backFileSize;
    birthdatemax;
    disableDateOfBirth = false;
     isFrontFileSizeError = false;
     isBackFileSizeError = false;
     isFrontFileFormatError = false;
     isBackFileFormatError = false;
          
     constructor() {
        super();
        this.getTodayDate();
     }
    //Recaptcha Changes
    recaptchaLoaded = false;
    captachResponse = '';
    hideCaptchaError = true;
    renderedCallback() {
        if(this.recaptchaLoaded) {
            return;
        }
        document.addEventListener("grecaptchaVerified",e => {
            this.captachResponse = e.detail.response;
            this.hideCaptchaError = true;
        });
        document.addEventListener("grecaptchaExpired",() => {
            this.captachResponse = '';
            //this.hideCaptchaError = false;
        });
        document.addEventListener("grecaptchaError",() => {
            this.captachResponse = '';
            //this.hideCaptchaError = false;
        });
        var divElement = this.template.querySelector('.recaptchaCheckbox');
        //valide values for badge: bottomright bottomleft inline
        
        if(divElement) {
            var payload = {element: divElement, badge: 'bottomright'};
            document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
            this.recaptchaLoaded = true;
        }

    }
    //confirm email address
    hcpConfirmEmailNoMatch = HCP_CONFIRM_EMAIL_NO_MATCH;
    hcpConfirmEmailAddress = HCP_CONFIRM_EMAIL;
     // disable paste , drap and drop
     handlePaste(event) {
        event.preventDefault();
    }
    confirmEmailFocus(event) {
       const style = document.createElement('style');
        style.innerText = `c-lwc-hcp-user-registration-brazil .email-address .slds-input {
            color: transparent;
            text-shadow: 0 0 5px rgba(0,0,0,0.5);
            }`;
       this.template.querySelector('.email-address').appendChild(style);
    }

    confirmEmailValidateEvent() {
        const style = document.createElement('style');
        style.innerText = `c-lwc-hcp-user-registration-brazil .email-address .slds-input {
            color: black;
            text-shadow: none;
            }`;
        this.template.querySelector('.email-address').appendChild(style);
        confirmEmailValidation(this.template, true);
    }
    confirmPasswordValidateEvent() {
        confirmPasswordValidation(this.template);
    }

    connectedCallback() {
        this.labelsImported = getLabels();
        getPicklistValuesContact()
        .then(data => {
            this.comboBoxOptions = Object.assign({}, data);
            this.showContent = true;
            this.isDoctor = this.comboBoxOptions.Profession__cDefault;
        })
        .catch(error => {
            console.log(error);
            this.showContent = true;
        })
        this.specialityOptionsUpdate();
        this.getTodayDate();
    }
    
    tabEventInProgress = false;
    emailKeyupEvent(event) {
        if((event.keyCode || event.which) == 9) {
            
            // this.validateEmailAddress(event);
            this.template.querySelectorAll('.confirm-email-address')[0].disabled = false;
            this.tabEventInProgress = true;
            //this.validateEmailAddress(event);
            // event.preventDefault();
           
        }
    }

    validateEmailAddress(event) {
        //start the spinner
        this.isLoading = true;
        //Query thr input email field
        let inputCmp = this.template.querySelector('.email-address');
        //call the shared js from the utility to validate the email address. This function returns a promise. Hide the spinner once the promsie is completed
        validateEmailAddressFunc(inputCmp, 'Brazil', this.hcpEmailExists, this.hcpEmailInvalid, this.template, this.tabEventInProgress)
        .then(result => {
            confirmEmailValidation(this.template);
            this.isLoading = false;
            this.tabEventInProgress = false;
        })
        .catch(error => {
            this.isLoading = false;
            this.tabEventInProgress = false;
        });
    }

    submitRegistrationforBrazil(template, cmpContext) {
        

        //Passwords validation
        let passCmp = template.querySelector('.password');
        let passwordValue = passCmp.value || '';
        let confirmPassCmp = template.querySelector('.confirm-password');
        let isPasswordValid = passwordValue.match(/[a-z]/g) && passwordValue.match(/[A-Z]/g) 
                                && passwordValue.match(/[0-9]/g) && passwordValue.length >= 10
                                && (new RegExp('[!,%,&,@,#,$,^,*,?,_,~]')).test(passwordValue);
        let confirmPasswordValid = passwordValue == confirmPassCmp.value; 
        //passCmp.setCustomValidity(isPasswordValid && passwordValue ? '' : this.labelsImported.hcpPasswordWeak);
        passCmp.setCustomValidity(isPasswordValid && passwordValue ? '' : this.hcpValueMissing);
        passCmp.reportValidity();
        confirmPassCmp.setCustomValidity(confirmPasswordValid ? '' : this.labelsImported.hcpPasswordNoMatch);
        confirmPassCmp.reportValidity();

        let inputFieldValuesWrapper = {};
        template.querySelector('.error-message-submit').classList.add('error-hide');
        //Check whether all the innput fields are valid or not
        const allValid = [
            ...template.querySelectorAll('.reg-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            inputFieldValuesWrapper[inputCmp.dataset.wrapperparam] = inputCmp.value;
            return validSoFar && inputCmp.checkValidity();
        }, true);
        //Check whether all the input checkboxe fields are valid or not
        const allConsentsValid = [
            ...template.querySelectorAll('.checkbox-reg'),
        ].reduce((validSoFar, inputCmp) => {
            const isChekboxValid = validateCheckboxUtility(inputCmp, template);
            inputFieldValuesWrapper[inputCmp.dataset.wrapperparam] = inputCmp.checked;
            return validSoFar && isChekboxValid;
        }, true);
        let captachValid = false;
        captachValid = this.hideCaptchaError = this.captachResponse != '';
        //Execute server side code to create the user registration data if all fields are valid
        if (allValid && allConsentsValid && isPasswordValid && confirmPasswordValid && this.validateFiles() && captachValid) {
            //submit the form to create contact and consent data
            inputFieldValuesWrapper.password = passwordValue;
            //start the spinner
            cmpContext.isLoading = true;
            submitRegistrationBrazil({ wrapper: inputFieldValuesWrapper })
            .then(result => {
                this.resultMap = [];
                for (var key in result) {
                this.resultMap.push({ key: key, value: result[key] });
                console.log('key', key, result[key]);
                }
                if(key == 'Success') {
                    this.contactRecordId = result[key];//
                    console.log('frontfileData=='+this.frontfileData)
                    if(this.frontfileData != null && this.frontfileData != undefined){
                        this.submitFile(this.frontfileData,'frontImage');
                    }else{
                        cmpContext.isLoading = false;
                    }
                }
                else {
                    template.querySelector('.error-message-submit').classList.remove('error-hide');
                    cmpContext.isLoading = false;
                }
                
            })
            .catch(error => {
                template.querySelector('.error-message-submit').classList.remove('error-hide');
                cmpContext.isLoading = false;
            });
        }
        else {
            //hide the spinner if all fields are not valid
            cmpContext.isLoading = false;
        }
    }

     //called on click of the submission button
     submitRegistration() {
            this.submitRegistrationforBrazil(this.template, this);
       
     }
     //validate file
     validateFiles(){
        var isValidfrontfileData = false;
        var isValidbackfileData = false;
        if(this.frontfileData == null || this.frontfileData == undefined){
            this.template.querySelector('.error-message-submit').classList.remove('error-hide');
            isValidfrontfileData = false;
        }else if(this.isFrontFileSizeError || this.isFrontFileFormatError){
            this.template.querySelector('.error-message-submit').classList.remove('error-hide');
               isValidfrontfileData = false;
        }else{
            isValidfrontfileData = true;
        }

        if(this.backfileData == null || this.backfileData == undefined){
            isValidbackfileData = true;
        }else if(this.isBackFileSizeError || this.isBackFileFormatError){
            this.template.querySelector('.error-message-submit').classList.remove('error-hide');
            isValidbackfileData = false;
        }else{
            isValidbackfileData = true;
        }
        
        if(isValidfrontfileData && isValidbackfileData){
            
            return true;
        }
        return false;
     }
    //validates the checkbox if it is required. called from UI
    validateCheckboxEvent(event) {
        validateCheckboxUtility(event.target, this.template);
    }
    //replaces the text characters with balnks if the field type is number.
    handleNumberChange(event) {
        const changedValue = event.target.value ? event.target.value  : '';
        this.template.querySelector("#" + event.target.id).value = changedValue.replace(/[^0-9\.]/g,'');
        
    }
     
    handleFileUpload(event) {
        
            if(event.target.name =='frontImage'){
                const file = event.target.files[0]
                
               var reader = new FileReader()
               reader.onload = () => {
                   var base64 = reader.result.split(',')[1]
                   this.frontfileData = {
                       'filename': file.name,
                       'base64': base64
                   }
                 
                   console.log(this.frontfileData)
                 }
               reader.readAsDataURL(file);
               if(!this.validateFileType(file)){
                //alert('Invalid file type. Please upload a JPEG, PNG, or PDF file.');
                this.isFrontFileFormatError = true;
                this.isFrontFileSizeError = false;
                event.target.value = '';

              }else if (event.target.files[0].size > MAX_FILE_SIZE) {
                this.frontFileSize = 0;
                this.frontFileSize = this.formatBytes(event.target.files[0].size);
                this.isFrontFileSizeError = true;
                this.isFrontFileFormatError = false;
               }else{
                this.isFrontFileSizeError = false;
                this.isFrontFileFormatError = false;
             }
            }

             if(event.target.name =='backImage'){
               const file = event.target.files[0]
              var reader = new FileReader()
              reader.onload = () => {
                  var base64 = reader.result.split(',')[1]
                  this.backfileData = {
                      'filename': file.name,
                      'base64': base64
                  }
                  console.log(this.backfileData)
                }
              reader.readAsDataURL(file);
              if(!this.validateFileType(file)){
                //alert('Invalid file type. Please upload a JPEG, PNG, or PDF file.');
                this.isBackFileFormatError = true;
                this.isBackFileSizeError = false;
              }else if (event.target.files[0].size > MAX_FILE_SIZE) {
                this.backFileSize = 0;
                this.backFileSize = this.formatBytes(event.target.files[0].size);
                this.isBackFileSizeError = true;
                this.isBackFileFormatError = false;
               }else{
                this.isBackFileSizeError = false;
                this.isBackFileFormatError = false;
               }
            }
        
    }
     submitFile(fileData,filetype){
                //start the spinner
        this.isLoading = true;
        //const {base64, filename} = this.fileData
        var base64 = fileData.base64;
        var filename = fileData.filename;
                 uploadFile({ 
            base64 : base64, 
            filename : filename, 
            recordId : this.contactRecordId,
            fileType: filetype
        }).then(result=>{
            if(result == 'SuccessfrontImage') {
                //upload backfile after front file is successful
                if(this.backfileData != null && this.backfileData != undefined){
                    this.submitFile(this.backfileData,'backImage');
                }else{
                    this.isLoading = false;
                    window.open(HCP_SUCCESS_URL, "_self");
                }
            }else if(result == 'SuccessbackImage'){
                this.isLoading = false;
                window.open(HCP_SUCCESS_URL, "_self");
            }else if(result.includes('Error')){
                this.isServiceError = true;
                this.isLoading = false;
                passCmp.setCustomValidity(this.hcpValueMissing);
                passCmp.reportValidity();
                template.querySelector('.error-message-submit').classList.remove('error-hide');
            }else{
                this.deleteContactRecord();
                template.querySelector('.error-message-submit').classList.remove('error-hide');
            } 
            
        })
        .catch(error => {
            this.deleteContactRecord();
            template.querySelector('.error-message-submit').classList.remove('error-hide');
        }); 
        
    }
    deleteContactRecord() {
        this.isLoading = true;
        deleteRecord(this.contactRecordId)
          .then(() => {
            this.isLoading = false;
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error with registration ",
                message: "File upload is failed",
                variant: "error"
              }),
            );
    
          })
          this.isLoading = false;
        }

    removeFrontImage() {
        this.frontfileData = null;
    }
    removeBackImage() {
        this.backfileData = null;
    }
      
    professionchange(event){
        this.value = event.target.value;
        let selectedProfession = this.value;
        this.specialityOptions = [];

        switch (selectedProfession) {
            case 'Biomedical Scientist':
                this.specialityDefaultvalue = "Biomedical Scientist";
                this.specialityOptions.push({label: "Biomédico/a", value: "Biomedical Scientist"});
                break;
            case 'Dentist':
                this.specialityDefaultvalue = "Dentist";
                this.specialityOptions.push({label: "Dentista", value: "Dentist"});
                break;
            case 'Nurse':
                this.specialityDefaultvalue = "Nurse";
                this.specialityOptions.push({label: "Enfermeiro/a", value: "Nurse"});
                break;
            case 'Pharmacist':
                this.specialityDefaultvalue = "Pharmacist";
                this.specialityOptions.push({label: "Farmacêutico/a", value: "Pharmacist"});
                break;
            case 'Doctor':
                this.specialityDefaultvalue = "Aesthetic Medicine";
                this.specialityOptionsUpdate();
                break;
            
        }
    }
    specialityOptionsUpdate(){
                this.specialityOptions.push({label: "Medicina Estética", value: "Aesthetic Medicine"});
                this.specialityOptions.push({label: "Alergia e Imunologia", value: "Allergy and Immunology"});
                this.specialityOptions.push({label: "Anestesiologia", value: "Anesthesiology"});
                this.specialityOptions.push({label: "Cardiologia", value: "Cardiology"});
                this.specialityOptions.push({label: "Cirurgia Cardiovascular", value: "Cardiovascular Surgery"});
                this.specialityOptions.push({label: "Coloproctologia", value: "Coloproctology"});
                this.specialityOptions.push({label: "Dermatologista", value: "Dermatologist"});
                this.specialityOptions.push({label: "Endocrinologia e Metabologia", value: "Endocrinology and Metabology"});
                this.specialityOptions.push({label: "Gastroenterologia", value: "Gastroenterology"});
                this.specialityOptions.push({label: "Cirurgia Geral", value: "General Surgery"});
                this.specialityOptions.push({label: "Geriatria", value: "Geriatrics"});
                this.specialityOptions.push({label: "Ginecologia e Obstetrícia", value:"Gynecology and Obstetrics"});
                this.specialityOptions.push({label: "Infectologia", value: "Infectology"});
                this.specialityOptions.push({label: "Medicina Intensiva", value: "Intensive Care Medicine"});
                this.specialityOptions.push({label: "Clínica Médica", value: "Medical Clinic"});
                this.specialityOptions.push({label: "Genética Médica", value: "Medical Genetics"});
                this.specialityOptions.push({label: "Nefrologia", value: "Nephrology"});
                this.specialityOptions.push({label: "Neurologia", value: "Neurology"});
                this.specialityOptions.push({label: "Nutrologia", value: "Nutrology"});
                this.specialityOptions.push({label: "Medicina do Trabalho", value: "Occupational Medicine"});
                this.specialityOptions.push({label: "Oftalmologia", value: "Ophthalmology"});
                this.specialityOptions.push({label: "Ortopedia e Traumatologia", value:"Orthopedics and Traumatology"});
                this.specialityOptions.push({label: "Otorrinolaringologia", value: "Otorhinolaryngology"});
                this.specialityOptions.push({label: "Pediatria", value: "Paediatrics"});
                this.specialityOptions.push({label: "Patologia", value: "Pathology"});
                this.specialityOptions.push({label: "Cirurgia Pediátrica", value: "Pediatric Surgery"});
                this.specialityOptions.push({label: "Medicina Física e Reabilitação", value: "Physical Medicine and Rehabilitation"});
                this.specialityOptions.push({label: "Cirurgia Plástica", value: "Plastic Surgery"});
                this.specialityOptions.push({label: "Psiquiatria", value: "Psychiatry"});
                this.specialityOptions.push({label: "Pneumologia", value: "Pulomonology"});
                this.specialityOptions.push({label: "Radiologia e Diagnóstico por Imagem", value:"Radiology and Diagnostic Imaging"});
                this.specialityOptions.push({label: "Radioterapia", value: "Radiotherapy"});
                this.specialityOptions.push({label: "Dermatologista Residente", value: "Resident Dermatologist"});
                this.specialityOptions.push({label: "Cirurgia Plástica Residente", value: "Resident Plastic Surgery"});
                this.specialityOptions.push({label: "Cirurgia Toráxica", value: "Thoracic Surgery"});
                this.specialityOptions.push({label: "Outros", value: "Others"});

    }
    showToast(title, variant, message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                variant: variant,
                message: message,
            })
        );
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Toast Error',
            message: 'Some unexpected error',
            variant: 'error',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }
    

    

 handleFormatConversion(event){
   if(event.target.name =='cpfNumber'){   
        event.target.value = this.autoFormatCpf(event.target.value);
        return ;    
    }
    if(event.target.name =='phoneNumber'){
        event.target.value = this.autoFormatPhoneNumber(event.target.value);
        return ;
    }
}

autoFormatCpf(cpfString) {
	try {
		var cleaned = ("" + cpfString).replace(/\D/g, "");
		var match = cleaned.match(/^(\d{0,3})?(\d{0,3})?(\d{0,3})?(\d{0,2})?$/);
		// var intlCode = match[1] ? "+1 " : "";
		return [match[1], 
						match[2] ? ".": "",
						match[2], 
						match[3] ? ".": "",
						match[3],
						match[4] ? "-": "",
						match[4]].join("")
		
	} catch(err) {
		return "";
	}
}

autoFormatPhoneNumber(phoneNumberString) {
	try {
		var cleaned = ("" + phoneNumberString).replace(/\D/g, "");
		var match = cleaned.match(/^(\d{0,2})?(\d{0,5})?(\d{0,4})?$/);
		// var intlCode = match[1] ? "+1 " : "";
		return [match[1] ? "(": "",
						match[1], 
						match[2] ? ")": "",
						match[2],
						match[3] ? "-": "",
						match[3]].join("")
		
	} catch(err) {
		return "";
	}
}
   getTodayDate(){
        // Get the current date/time in UTC
        let rightNow = new Date();

        // Adjust for the user's time zone
        rightNow.setMinutes(
            new Date().getMinutes() - new Date().getTimezoneOffset()
        );

        // Return the date in "YYYY-MM-DD" format
        let yyyyMmDd = rightNow.toISOString().slice(0,10);
        console.log(yyyyMmDd); // Displays the user's current date, e.g. "2020-05-15"
        this.birthdatemax = yyyyMmDd;
   }
   disableFuction(event){
    var selectedDate = event.target.value;
    if(selectedDate > this.birthdatemax)
          this.disableDateOfBirth = true;
   }
   formatBytes(bytes, decimals = 2) {
    if (!+bytes) return '0 Bytes'

    const k = 1024
    const dm = decimals < 0 ? 0 : decimals
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']

    const i = Math.floor(Math.log(bytes) / Math.log(k))

    return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
}

validateFileType(selectedFile) {
    
    var allowedTypes = ['image/jpeg', 'image/png', 'application/pdf','HEIF','HEIC'];

    if(selectedFile.type == ''){
         var extensions = selectedFile.name.split('.');
         if(extensions[extensions.length-1]){
            
            if (allowedTypes.includes(extensions[extensions.length-1].toUpperCase())) {
                return true;
            
            }
         }
    }

    if (!allowedTypes.includes(selectedFile.type)) {
        return false;
       
    }
    return true;
 }

 labelsImported = {};

 hidePasswordReqBox() {
     this.template.querySelector('[data-id="passwordsection"]').classList.add("hide-section");
 }
 handlePasswordInput() {
     validatePassword(this.template);
 }

 confirmPasswordValidateEvent() {
     confirmPasswordValidation(this.template);
 }

}