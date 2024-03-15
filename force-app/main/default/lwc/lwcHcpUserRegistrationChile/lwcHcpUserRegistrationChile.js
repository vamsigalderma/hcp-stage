import { LightningElement, api } from 'lwc';
//Import Apex Methods
import getPicklistValuesContact from "@salesforce/apex/HCPUSerRegistrationController.getPicklistValues";

//Error Messages
import HCP_VALUE_MISSING from '@salesforce/label/c.HCPValueMissing';
import HCP_EMAIL_EXISTS from '@salesforce/label/c.HCPEmailAddressExists';
import HCP_EMAIL_INVALID from '@salesforce/label/c.HCPEmailAddressInvalid';
import HCP_INVALID_MEDICAL_ID from '@salesforce/label/c.HCPInvalidMedicalId';
import HCP_INVALID_PHONE from '@salesforce/label/c.HCPInvalidPhone';
import HCP_INVALID_ZIP from '@salesforce/label/c.HCPInvalidZip';
//Form Field Labels
import HCP_TITLE from '@salesforce/label/c.HCPTitle';
import HCP_FIRST_NAME from '@salesforce/label/c.HCPFirstName';
import HCP_LAST_NAME from '@salesforce/label/c.HCPLastName';
import HCP_EMAIL from '@salesforce/label/c.HCPEmailAddress';
import HCP_CONFIRM_EMAIL from '@salesforce/label/c.HCPConfirmEmailAddress';
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


import {validateEmailAddressFunc, submitRegistrationUtility, validateCheckboxUtility, 
    getLabels, validatePassword, confirmPasswordValidation, confirmEmailValidation} from 'c/lwcHcpJsUtility';

export default class LwcHcpUserRegistrationChile extends LightningElement {
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
    //field labels - translated values from the custom labels
    hcpTitle = HCP_TITLE;
    hcpFirstName = HCP_FIRST_NAME;
    hcpLastName = HCP_LAST_NAME;
    hcpEmailAddress = HCP_EMAIL;
    hcpConfirmEmailAddress = HCP_CONFIRM_EMAIL;
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
    hcpConfirmEmailAddress = HCP_CONFIRM_EMAIL;
     // disable paste , drap and drop
     handlePaste(event) {
        event.preventDefault();
    }
    confirmEmailFocus(event) {
       const style = document.createElement('style');
        style.innerText = `c-lwc-hcp-user-registration-chile .email-address .slds-input {
            color: transparent;
            text-shadow: 0 0 5px rgba(0,0,0,0.5);
            }`;
       this.template.querySelector('.email-address').appendChild(style);
    }

    confirmEmailValidateEvent() {
        const style = document.createElement('style');
        style.innerText = `c-lwc-hcp-user-registration-chile .email-address .slds-input {
            color: black;
            text-shadow: none;
            }`;
        this.template.querySelector('.email-address').appendChild(style);
        confirmEmailValidation(this.template, true);
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
        if(this.isLoading) {
            return;
        }
        this.isLoading = true;
        //Query thr input email field
        let inputCmp = this.template.querySelector('.email-address');
        //call the shared js from the utility to validate the email address. This function returns a promise. Hide the spinner once the promsie is completed
        validateEmailAddressFunc(inputCmp, 'Chile', this.hcpEmailExists, this.hcpEmailInvalid, this.template, this.tabEventInProgress)
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

     //called on click of the submission button
     submitRegistration(event) {
        submitRegistrationUtility(this.template, this);  
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
    
    labelsImported = {};
    hidePasswordReqBox() {
        this.template.querySelector('[data-id="passwordsection"]').classList.add("hide-section");
    }
    handlePasswordInput() {
        validatePassword(this.template);
        // let passCmp = this.template.querySelector('.password');
        // let passwordValue = event.target.value;
        // this.password = passwordValue;
        // let errorMessage = '';
        // // Validate lowercase letters
        // let lowerCaseLetters = /[a-z]/g;
        // if (passwordValue.match(lowerCaseLetters)) {
        //     this.template.querySelector('[data-id="letter"]').classList.add("pr-ok");
        // } 
        // else {
        //     this.template.querySelector('[data-id="letter"]').classList.remove("pr-ok");
        //     errorMessage = this.labelsImported.hcpPasswordWeak;
        // }

        // // Validate capital letters
        // let upperCaseLetters = /[A-Z]/g;
        // if (passwordValue.match(upperCaseLetters)) {
        //     this.template.querySelector('[data-id="upper"]').classList.add("pr-ok");
        // } else {
        //     this.template.querySelector('[data-id="upper"]').classList.remove("pr-ok");
        //     errorMessage = this.labelsImported.hcpPasswordWeak;
        // }
        // // Validate numbers
        // let numbers = /[0-9]/g;
        // if (passwordValue.match(numbers)) {
        //     this.template.querySelector('[data-id="number"]').classList.add("pr-ok");
        // } else {
        //     this.template.querySelector('[data-id="number"]').classList.remove("pr-ok");
        //     errorMessage = this.labelsImported.hcpPasswordWeak;
        // }
        // // Validate length
        // if (passwordValue.length >= 10) {
        //     this.template.querySelector('[data-id="length"]').classList.add("pr-ok");
        // } else {
        //     this.template.querySelector('[data-id="length"]').classList.remove("pr-ok");
        //     errorMessage = this.labelsImported.hcpPasswordWeak;
        // }
        // //special characters
        // let	specialCharacter = new RegExp('[!,%,&,@,#,$,^,*,?,_,~]');
        // if (specialCharacter.test(passwordValue)) {
        //     this.template.querySelector('[data-id="special"]').classList.add("pr-ok");
        // }
        // else {
        //     this.template.querySelector('[data-id="special"]').classList.remove("pr-ok");
        //     errorMessage = this.labelsImported.hcpPasswordWeak;
        // }
        // passCmp.setCustomValidity(errorMessage);
        // passCmp.reportValidity();

    }

    confirmPasswordValidateEvent() {
        // let passCmp = this.template.querySelector('.password');
        // let inputCmp = this.template.querySelector('.confirm-password');
        // if(passCmp.value && inputCmp.value && passCmp.value != inputCmp.value) {
        //     inputCmp.setCustomValidity(this.labelsImported.hcpPasswordNoMatch);
        //     inputCmp.reportValidity();
        // }
        // else {
        //     inputCmp.setCustomValidity('');
        //     inputCmp.reportValidity();
        // }
        confirmPasswordValidation(this.template);
    }
 
}