import checkDuplicateContacts from "@salesforce/apex/HCPUSerRegistrationController.checkDuplicateContacts";
import HCP_SUCCESS_URL from '@salesforce/label/c.hcpSuccessUrl';
import submitRegistration from "@salesforce/apex/HCPUSerRegistrationController.submitRegistration";

//Labels
import HCP_PASSWORD_LABEL from '@salesforce/label/c.HCPPasswordLabel';
import HCP_CONFIRM_PASSWORD_LABEL from '@salesforce/label/c.HCPConfirmPasswordLabel';
import HCP_PASSWORD_WEAK from '@salesforce/label/c.HCPPasswordWeak';
import HCPPasswordInstructions from '@salesforce/label/c.HCPPasswordInstructions';
import HCPPasswordLength from '@salesforce/label/c.HCPPasswordLength';
import HCPPasswordLower from '@salesforce/label/c.HCPPasswordLower';
import HCPPasswordUpper from '@salesforce/label/c.HCPPasswordUpper';
import HCPPasswordNumber from '@salesforce/label/c.HCPPasswordNumber';
import HCPPasswordSpecial from '@salesforce/label/c.HCPPasswordSpecial';
import HCPPasswordNoMatch from '@salesforce/label/c.HCPPasswordNoMatch';
import HCP_CONFIRM_EMAIL_NO_MATCH from '@salesforce/label/c.HCPConfirmEmailNoMatch';
import HCPProcessingErrorMsg from '@salesforce/label/c.HCPProcessingErrorMsg';
import HCPValueMissing from '@salesforce/label/c.HCPValueMissing';
import HCPCaptchaError from '@salesforce/label/c.HCPCaptchaError';

function setFocusOnPassword(cnfCmp, template, tabEventInProgress) {
    cnfCmp.disabled = true;
    cnfCmp.value = '';
    cnfCmp.setCustomValidity('');
    cnfCmp.reportValidity();
    if(tabEventInProgress) {
        template.querySelector('.password').focus();
    }
   
}

function setFocusOnConfirmEmail(cnfCmp, tabEventInProgress) {
    cnfCmp.disabled = false;
    
}

//Validate the whether the entered email address in valid format.
//If the email address is valid => checks whether email is duplicate ot not
function validateEmailAddressFunc(inputCmp, country, hcpEmailExists, hcpEmailInvalid, template, tabEventInProgress) {
    return new Promise(function(resolve, reject){
        let cnfCmp = template.querySelectorAll('.confirm-email-address')[0];
        const emailAddress = inputCmp.value;
        inputCmp.setCustomValidity('');
        //Regext test to check the format
        let isValidEmail = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(emailAddress);

        if(emailAddress && !isValidEmail) {
            inputCmp.setCustomValidity(hcpEmailInvalid);
        }
        else {
            inputCmp.setCustomValidity('');
        }
        let isValid =  inputCmp.checkValidity();
        if(isValid) {
            //check if the email address is duplicate
            inputCmp.setCustomValidity('');
            inputCmp.reportValidity();
            checkDuplicateContacts({ emailAddress: emailAddress, country: country })
            .then(result => {
                if(result) {
                    inputCmp.setCustomValidity(hcpEmailExists); 
                    inputCmp.reportValidity();
                     setFocusOnPassword(cnfCmp, template, tabEventInProgress);
                }
                else {
                    setFocusOnConfirmEmail(cnfCmp, tabEventInProgress);
                }
                resolve('validated');
            })
            .catch(error => {
                //error handling - show toast message
                resolve('validated');
            });
        }
        else {
            setFocusOnPassword(cnfCmp, template, tabEventInProgress);
            inputCmp.reportValidity();
            resolve('validated');
        }
        
    });
    
}
function submitRegistrationUtility(template, cmpContext) {
    //start the spinner
    cmpContext.isLoading = true;

     //Passwords validation
     let passCmp = template.querySelector('.password');
     let passwordValue = passCmp.value || '';
     let confirmPassCmp = template.querySelector('.confirm-password');
     let isPasswordValid = passwordValue.match(/[a-z]/g) && passwordValue.match(/[A-Z]/g) 
                             && passwordValue.match(/[0-9]/g) && passwordValue.length >= 10
                             && (new RegExp('[!,%,&,@,#,$,^,*,?,_,~]')).test(passwordValue);
     let confirmPasswordValid = passwordValue == confirmPassCmp.value;
     passCmp.setCustomValidity(isPasswordValid && passwordValue ? '' : HCPValueMissing);
     passCmp.reportValidity();
     confirmPassCmp.setCustomValidity(confirmPasswordValid ? '' : HCPPasswordNoMatch);
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
    captachValid = cmpContext.hideCaptchaError = cmpContext.captachResponse != '';
    //Execute server side code to create the user registration data if all fields are valid
    if (allValid && allConsentsValid && isPasswordValid && confirmPasswordValid && captachValid) {
        //submit the form to create contact and consent data
        inputFieldValuesWrapper.password = passwordValue;
        submitRegistration({ wrapper: inputFieldValuesWrapper })
        .then(result => {
            if(result == 'Success') {
                window.open(HCP_SUCCESS_URL, "_self");
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

function validateCheckboxUtility(cmp, template) {
   let checked = cmp.checked;
   if(cmp.required) {
       let parentDiv = template.querySelectorAll(cmp.dataset.parentdiv);
       let errorDiv = template.querySelectorAll(cmp.dataset.errordiv);

       if(parentDiv.length > 0) {
           if(checked){
               parentDiv[0].classList.remove('slds-has-error');
           }
           else {
               parentDiv[0].classList.add('slds-has-error');
           }
           
       }
       
       if(errorDiv.length > 0) {
           if(checked){
               errorDiv[0].classList.add('error-hide');
           }
           else {
               errorDiv[0].classList.remove('error-hide');
           }
           
       }
   }

   return (checked && cmp.required) || !cmp.required;
}

const getLabels = () => {
    return {
        hcpPasswordLabel: HCP_PASSWORD_LABEL,
        hcpConfirmPasswordLabel: HCP_CONFIRM_PASSWORD_LABEL,
        hcpPasswordWeak: HCP_PASSWORD_WEAK,
        hcpPasswordInstructions: HCPPasswordInstructions,
        hcpPasswordLength: HCPPasswordLength,
        hcpPasswordLower: HCPPasswordLower,
        hcpPasswordUpper: HCPPasswordUpper,
        hcpPasswordNumber: HCPPasswordNumber,
        hcpPasswordSpecial: HCPPasswordSpecial,
        hcpPasswordNoMatch: HCPPasswordNoMatch,
        hcpConfirmEmailNoMatch: HCP_CONFIRM_EMAIL_NO_MATCH,
        hcpProcessingErrorMsg :HCPProcessingErrorMsg,
        hcpCaptchaError: HCPCaptchaError
    };
};

const validatePassword = (template) => {
    let passCmp = template.querySelector('.password');
    let passwordValue = passCmp.value;
   
    let errorMessage = '';
    // Validate lowercase letters
    let lowerCaseLetters = /[a-z]/g;
    if (passwordValue.match(lowerCaseLetters)) {
        template.querySelector('[data-id="letter"]').classList.add("pr-ok");
    } 
    else {
        template.querySelector('[data-id="letter"]').classList.remove("pr-ok");
        errorMessage = HCP_PASSWORD_WEAK;
    }

    // Validate capital letters
    let upperCaseLetters = /[A-Z]/g;
    if (passwordValue.match(upperCaseLetters)) {
        template.querySelector('[data-id="upper"]').classList.add("pr-ok");
    } else {
        template.querySelector('[data-id="upper"]').classList.remove("pr-ok");
        errorMessage = HCP_PASSWORD_WEAK;
    }
    // Validate numbers
    let numbers = /[0-9]/g;
    if (passwordValue.match(numbers)) {
        template.querySelector('[data-id="number"]').classList.add("pr-ok");
    } else {
        template.querySelector('[data-id="number"]').classList.remove("pr-ok");
        errorMessage = HCP_PASSWORD_WEAK;
    }
    // Validate length
    if (passwordValue.length >= 10) {
        template.querySelector('[data-id="length"]').classList.add("pr-ok");
    } else {
        template.querySelector('[data-id="length"]').classList.remove("pr-ok");
        errorMessage = HCP_PASSWORD_WEAK;
    }
    //special characters
    let	specialCharacter = new RegExp('[!,%,&,@,#,$,^,*,?,_,~]');
    if (specialCharacter.test(passwordValue)) {
        template.querySelector('[data-id="special"]').classList.add("pr-ok");
    }
    else {
        template.querySelector('[data-id="special"]').classList.remove("pr-ok");
        errorMessage = HCP_PASSWORD_WEAK;
    }

    errorMessage = passwordValue ? errorMessage : '';
    passCmp.setCustomValidity(errorMessage);
    passCmp.reportValidity();
    
    if(errorMessage) {
        template.querySelector('[data-id="passwordsection"]').classList.remove("hide-section");
    }
    else {
        template.querySelector('[data-id="passwordsection"]').classList.add("hide-section");
    }
}

const confirmPasswordValidation = (template) => {
    let passCmp = template.querySelector('.password');
    let inputCmp = template.querySelector('.confirm-password');
    if(passCmp.value && inputCmp.value && passCmp.value != inputCmp.value) {
        inputCmp.setCustomValidity(HCPPasswordNoMatch);
        inputCmp.reportValidity();
    }
    else {
        inputCmp.setCustomValidity('');
        inputCmp.reportValidity();
    }
}

const confirmEmailValidation = (template, checkValidityForBlank) => {
    
    let emailCmp = template.querySelector('.email-address');
    let inputCmp = template.querySelector('.confirm-email-address');
    if(emailCmp.value && inputCmp.value && (emailCmp.value).toLowerCase() != (inputCmp.value).toLowerCase()) {
        inputCmp.setCustomValidity(HCP_CONFIRM_EMAIL_NO_MATCH);
        inputCmp.reportValidity();
    }
    else if(checkValidityForBlank || inputCmp.value){
        inputCmp.setCustomValidity('');
        inputCmp.reportValidity();
    }
}

export { validateEmailAddressFunc, submitRegistrationUtility, validateCheckboxUtility, getLabels, validatePassword, confirmPasswordValidation,confirmEmailValidation};