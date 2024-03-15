import { LightningElement, wire } from 'lwc';
import loginImageResource from '@salesforce/resourceUrl/hcpLoginImage';
import galderma_logo from '@salesforce/resourceUrl/GALDERMA_LOGO';
import { CurrentPageReference } from 'lightning/navigation';
import doLogin from '@salesforce/apex/CommunityAuthController.doLogin';
import checkMigratedUser from '@salesforce/apex/CommunityAuthController.checkMigratedUser';
import resetGcUserPassword from '@salesforce/apex/HCPUserManagement.resetGcUserPassword';
import HCP_VALUE_MISSING from '@salesforce/label/c.HCPValueMissing';

import LOGINTITLE from '@salesforce/label/c.LoginTitle';
import LOGINHEADER from '@salesforce/label/c.LoginHeader';
import LOGINITEM1 from '@salesforce/label/c.LoginItem1';
import LOGINITEM2 from '@salesforce/label/c.LoginItem2';
import LOGINITEM3 from '@salesforce/label/c.LoginItem3';
import LOGINDETAILSHEADER from '@salesforce/label/c.LoginDetailsHeader';
import LOGINEMAILLABEL from '@salesforce/label/c.LoginEmailLabel';
import LOGINPASSWORDLABEL from '@salesforce/label/c.LoginPasswordLabel';
import FORGOTPASSWORDLABEL from '@salesforce/label/c.ForgotPasswordLabel';
import ACCOUNTCREATIONLABEL from '@salesforce/label/c.AccountCreationLabel';
import RESENDVERIFICATIONLABEL from '@salesforce/label/c.ResendVerificationLabel';
import LOGINERROR from '@salesforce/label/c.LoginError';
import LOGINLABEL from '@salesforce/label/c.LoginLabel';
import HCPMigratedUserMsg from '@salesforce/label/c.HCPMigratedUserMsg';
import HCpCountryLoginUrl from '@salesforce/label/c.HCpCountryLoginUrl';
import LOGINEMAILPLACEHOLDERLABEL from '@salesforce/label/c.LoginEmailPlaceholderLabel';
import LOGINPASSWORDPLACEHOLDERLABEL from '@salesforce/label/c.LoginPasswordPlaceholderLabel';
import HCPValidationError from '@salesforce/label/c.HCPValidationError';
import HCPVerificationError from '@salesforce/label/c.HCPVerificationError';
import HCPLoginErrorThailand from '@salesforce/label/c.HCPLoginErrorThailand';

export default class HcpLoginForm extends LightningElement {

    logintitle = LOGINTITLE;
    loginheader = LOGINHEADER;
    loginitem1 = LOGINITEM1;
    loginitem2 = LOGINITEM2;
    loginitem3 = LOGINITEM3;
    logindetailsheader = LOGINDETAILSHEADER;
    loginemaillabel = LOGINEMAILLABEL;
    loginpasswordlabel = LOGINPASSWORDLABEL;
    forgotpasswordlabel = FORGOTPASSWORDLABEL;
    accountcreationlabel = ACCOUNTCREATIONLABEL;
    resendverificationlabel = RESENDVERIFICATIONLABEL;
    loginerror = LOGINERROR;
    loginlabel = LOGINLABEL;
    hcpMigratedUserMsg = HCPMigratedUserMsg;
    hcpCountryLoginUrl = HCpCountryLoginUrl;
    loginemailplaceholderlabel = LOGINEMAILPLACEHOLDERLABEL;
    loginpwdplaceholderlabel = LOGINPASSWORDPLACEHOLDERLABEL;
    hcpVerificationError = HCPVerificationError;
    hcpValidationError = HCPValidationError;
    hcpLoginErrorThailand = HCPLoginErrorThailand;


    username;
    password;
    loginImage = loginImageResource;
    galdermaLogo = galderma_logo;
    hcpValueMissing = HCP_VALUE_MISSING;
    @wire(CurrentPageReference)
    currentPageReference;
    contetData;
    instructionsArray = [];
    isLoading = false;
    userreglink;
    resendemaillink;
    forgotpasswordlink;
    migratedUser = false;
    NotVerifiedUser = false;
    NotValidatedUser = false;
    loginSiteBrazil = false;

    constructor() {
        super();
        this.userreglink = window.location.origin+'/'+ window.location.pathname.substring(1,3) + '/user-registration';
        this.resendemaillink = this.hcpCountryLoginUrl.replace('samllogin', 'resend-verification-email');
        this.forgotpasswordlink = window.location.origin+'/'+ window.location.pathname.substring(1,3) + '/ForgotPassword';
        this.loginSiteBrazil = window.location.pathname.split ('/') [1] == 'br' ? true : false;
    }
    isFirstTime;
    renderedCallback() {
        if(this.isFirstTime) {
            return false;
        }
        const formHtml = this.template.querySelector('form');
		formHtml.addEventListener('submit', this.login.bind(this));
		//this.template.querySelector('.email-address').addEventListener('input',  this.validateEmail.bind(this));
		this.isFirstTime = true;
    }

    login(event) {
        console.log('login ++ start');
        event.preventDefault();
        this.isLoading = true;
        //const emailAddress = event.target.value;
		// let inputCmpEmail = this.template.querySelectorAll('.reg-input')[0];
        // inputCmpEmail.setCustomValidity('');

        let startUrl = this.currentPageReference.state.startURL;
        this.template.querySelector('.error-message-submit').classList.add('error-hide');
        const allValid = [
            ...this.template.querySelectorAll('.reg-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if(allValid) {
            if(this.migratedUser) {
                resetGcUserPassword({ emailAddress : this.username })
                .then((result) => {
                    let regButton = this.template.querySelector('.reg-button');
                    regButton.style.setProperty("background-color", "#EAEBEC", "important");
                    regButton.disabled = true;
                    regButton.style.pointerEvents = 'none';
                                        this.isLoading = false;
                    console.log('login ++ end reset password');
                })
                .catch((error) => {
                    this.isLoading = false;
                });
            }
            
            else {
                let loginSite = window.location.pathname.split ('/') [1];
                doLogin({ username: this.username, password: this.password, startUrl: startUrl })

                .then((result) => {
                    window.open(result, '_self');
                    //this.isLoading = false;
                    console.log('login ++ end login func');
                })
                .catch((error) => {
                    this.isLoading = false;
                    this.error = error;      
                    this.errorCheck = true;
                    this.errorMessage = error.body.message;
                    this.loginerror =  loginSite == 'th' ? this.hcpLoginErrorThailand : error.body.message;
                    this.template.querySelector('.error-message-submit').classList.remove('error-hide');
                });
            }
            
            
        }
        else {
            this.isLoading = false;
        }
        
    }
    validateEmailAddressOnEnter(event) {
        console.log('validateEmailAddress Enter ++ start');
        if(event.keyCode == 13) {
            //alert('enter key');
            event.preventDefault();
            this.validateEmailAddress(event);
            //return;
        }
        console.log('validateEmailAddress Enter ++ end');
    }
    async validateEmailAddress(event){
        console.log('validateEmailAddress++ Start');
        this.isLoading = true;
        this.template.querySelector('.error-message-submit').classList.add('error-hide');
        let inputCmp = this.template.querySelector('.email-address');
        let isValidEmail = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(inputCmp.value);
        if(isValidEmail) {
            await this.doMigrateUserCheck(inputCmp.value);
            if((event.keyCode == 13 || event.which == 13) && !this.migratedUser && !this.NotVerifiedUser && !this.NotValidatedUser) {
                this.login(event);
            }
            
        }
        else {
            this.template.querySelector('.user-password').disabled = false;
            // this.template.querySelector('.error-message').style.display = 'none';
            this.isLoading = false;
            this.migratedUser = false;
            this.login(event);
        }


    }

    doMigrateUserCheck(emailAddress) {
        return checkMigratedUser({ emailAddress: emailAddress })
                .then((result) => {
                    //Migrated user
                    if(result == "MigratedUser") {
                        let regButton = this.template.querySelector('.reg-button');
                        regButton.disabled = false;
                        regButton.style.pointerEvents = 'all';
                        regButton.style.backgroundColor = '#f8f8f8';
                        regButton.focus();
                        this.template.querySelector('.user-password').value = '';
                        this.template.querySelector('.user-password').disabled = true;
                        this.template.querySelector('.user-password').reportValidity();
                        //this.template.querySelector('.reg-button').focus();
                        // this.template.querySelector('.error-message').style.display = 'block';
                       
                        this.isLoading = false;
                        
                        this.migratedUser = true;
                    }
                else if(result == "UserNotVerified") {
                        let regButton = this.template.querySelector('.reg-button');
                        regButton.disabled = true;
                        this.template.querySelector('.user-password').value = '';
                        this.template.querySelector('.user-password').disabled = true;
                        this.template.querySelector('.user-password').reportValidity();
                                                this.isLoading = false;
                        this.NotVerifiedUser = true;
                    }
                else if(result == "UserNotValidated") {
                        let regButton = this.template.querySelector('.reg-button');
                        regButton.disabled = true;
                        this.template.querySelector('.user-password').value = '';
                        this.template.querySelector('.user-password').disabled = true;
                        this.template.querySelector('.user-password').reportValidity();
                                                this.isLoading = false;
                        this.NotValidatedUser = true;
                    }
                    else {
                        //Not Migrated user
                        let regButton = this.template.querySelector('.reg-button');
                        regButton.disabled = false;
                        regButton.style.pointerEvents = 'all';
                        regButton.style.backgroundColor = '#f8f8f8';
                        this.template.querySelector('.user-password').disabled = false;
                        // this.template.querySelector('.error-message').style.display = 'none';
                        this.isLoading = false;
                        this.migratedUser = false;
                        this.NotVerifiedUser = false;
                        this.NotValidatedUser = false;
                    }
                    console.log('validateEmailAddress++ end');
                })
                .catch((error) => {
                    this.template.querySelector('.user-password').disabled = false;
                    // this.template.querySelector('.error-message').style.display = 'none';
                    this.isLoading = false;
                    this.migratedUser = false;
                });
    }

    handleUserNameChange(event){

        this.username = event.target.value;
    }

    handlePasswordChange(event){
        
        this.password = event.target.value;
    }

}