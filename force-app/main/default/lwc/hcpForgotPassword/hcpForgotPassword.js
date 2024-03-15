import { LightningElement, wire } from 'lwc';
import loginImageResource from '@salesforce/resourceUrl/hcpLoginImage';
import galderma_logo from '@salesforce/resourceUrl/GALDERMA_LOGO';
import checkDuplicateUsers from '@salesforce/apex/HCPUserManagement.checkUser';
import resetGcUserPassword from '@salesforce/apex/HCPUserManagement.resetGcUserPassword';
import HCP_VALUE_MISSING from '@salesforce/label/c.HCPValueMissing';
import HCP_EMAIL_INVALID from '@salesforce/label/c.HCPEmailAddressInvalid';
//Forgot Password Page Labels
import HCPBackToLogin from '@salesforce/label/c.HCPBackToLogin';
import HCPForgotPasswordTitle from '@salesforce/label/c.HCPForgotPasswordTitle';
import HCPFPText from '@salesforce/label/c.HCPFPText';
import HCPPwdCnfPara1 from '@salesforce/label/c.HCPPwdCnfPara1';
import HCPPwdCnfPara2 from '@salesforce/label/c.HCPPwdCnfPara2';
import HCPPwdCnfPara3 from '@salesforce/label/c.HCPPwdCnfPara3';
import HCPPwdSincerely from '@salesforce/label/c.HCPPwdSincerely';
import HCPPwdThankYou from '@salesforce/label/c.HCPPwdThankYou';
import HCPEmailAddressPlaceHolder from '@salesforce/label/c.HCPEmailAddressPlaceHolder';
import HCPPasswordSubmitBtnText from '@salesforce/label/c.HCPPasswordSubmitBtnText';
import HCPPasswordInvaliEmail from '@salesforce/label/c.HCPPasswordInvaliEmail';
import HCPPasswordNoEmail from '@salesforce/label/c.HCPPasswordNoEmail';
import HCpCountryLoginUrl from '@salesforce/label/c.HCpCountryLoginUrl';
import HCPDoYouHaveQnsUrl from '@salesforce/label/c.HCPDoYouHaveQnsUrl';
import HCPPwdTeam from '@salesforce/label/c.HCPPwdTeam';
import HCPPwdContactUsText from '@salesforce/label/c.HCPPwdContactUsText';



export default class HcpForgotPassword extends LightningElement {
	//ForgotPassword Labels Assignment
	hcpBackToLogin = HCPBackToLogin;
	hcpForgotPasswordTitle = HCPForgotPasswordTitle;
	hcpFPText = HCPFPText;
	hcpPwdCnfPara1 = HCPPwdCnfPara1;
	hcpPwdCnfPara2 = HCPPwdCnfPara2;
	hcpPwdCnfPara3 = HCPPwdCnfPara3;
	hcpPwdSincerely = HCPPwdSincerely;
	hcpPwdThankYou = HCPPwdThankYou;
	hcpPasswordInvaliEmail = HCPPasswordInvaliEmail;
	hcpPasswordNoEmail = HCPPasswordNoEmail;
	hcpEmailAddressPlaceHolder = HCPEmailAddressPlaceHolder;
	hcpPasswordSubmitBtnText = HCPPasswordSubmitBtnText;
	hcpCountryLoginUrl = HCpCountryLoginUrl;
	hcpDoYouHaveQnsUrl = HCPDoYouHaveQnsUrl;
	hcpPwdTeam = HCPPwdTeam;
	hcpPwdContactUsText = HCPPwdContactUsText;
	loginImage = loginImageResource;
	galdermaLogo = galderma_logo;
	hcpValueMissing = HCP_VALUE_MISSING;
	hcpEmailInvalid = HCP_EMAIL_INVALID;
	isLoading = false;
	showPasswordScreen = true;

	addedEventLisners = false;
	loginSiteBrazil = false;

	constructor() {
        super();
        this.loginSiteBrazil = window.location.pathname.split ('/') [1] == 'br';
    }

	renderedCallback() {
		if(this.addedEventLisners) {
			return;
		}
		const formHtml = this.template.querySelector('form');
		formHtml.addEventListener('submit', this.resetPassword.bind(this));
		//this.template.querySelector('.email-address').addEventListener('input',  this.validateEmail.bind(this));
		this.addedEventLisners = true;
	}
	handleSubmit(event) {
		event.preventDefault();
		alert(event.key + ' ' + event.keyCode + ' ' + event.which);
		return false;
	}
	checkForEnterKey(event){
		console.log('codes' + event.key + ' ' +event.keyCode + ' ' + event.code + ' ' + event.which);
		if(event.keyCode == 13 || event.which ==  13) {
			this.validateEmail(event);
		}
	}	//Validated email address
	validateEmail(event) {
		//check if email is valid or not
		this.isLoading = true;
		//const emailAddress = event.target.value;
		let inputCmp = this.template.querySelectorAll('.reg-input')[0];
		const emailAddress = inputCmp.value;
		inputCmp.setCustomValidity('');
		let buttonCmp = this.template.querySelectorAll('.reg-button')[0];
		buttonCmp.style.pointerEvents = 'none';
		buttonCmp.disabled = true;
		inputCmp.setCustomValidity('');
		//Regext test to check the format
		let isValidEmail = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/.test(emailAddress);
		if (!isValidEmail && emailAddress) {
			inputCmp.setCustomValidity(this.hcpPasswordInvaliEmail);
		}
		else {
			inputCmp.setCustomValidity('');
		}
		inputCmp.reportValidity();
		let isValid = inputCmp.checkValidity();
		if (isValid && emailAddress) {
			//call server side code to check whether any user exists with the entered email address.
			checkDuplicateUsers({ emailAddress: emailAddress })
				.then(result => {
					if (result) {
						inputCmp.setCustomValidity('');
						inputCmp.reportValidity();
						buttonCmp.style.pointerEvents = 'all';
						buttonCmp.disabled = false;
						if(event.keyCode == 13 || event.which == 13) {
							buttonCmp.focus();
						}
					}
					else {
						inputCmp.setCustomValidity(this.hcpPasswordNoEmail);
						buttonCmp.style.pointerEvents = 'none';
						buttonCmp.disabled = true;
						inputCmp.reportValidity();
					}
					this.isLoading = false;

				})
				.catch(error => {
					//error handling - show toast message
					this.isLoading = false;
				});
		}
		else {
			inputCmp.reportValidity();
			buttonCmp.style.pointerEvents = 'none';
			buttonCmp.disabled = true;
			this.isLoading = false;
		}
	}
	resetPassword(event) {
		event.preventDefault();
		this.isLoading = true;
		//assuming email is manadatory field on the UI
		let emailCmp = this.template.querySelectorAll('.reg-input')[0];
		const allValid = emailCmp.checkValidity();
		if (allValid && emailCmp.value) {
			//reset the password and show the error or success message to the customer
			//call server side method to reset the password
			resetGcUserPassword({ emailAddress: emailCmp.value })
				.then(result => {
					if (result) {
						//Success - hide the password page and show the success message
						// alert('success');
						this.showPasswordScreen = false;
					}
					else {
						//Error - hide the password page and show the success message
						this.showPasswordScreen = false;
					}
					this.isLoading = false;

				})
				.catch(error => {
					//error handling - show toast message
					this.isLoading = false;
				});
		}
		else {
			emailCmp.reportValidity();
			this.isLoading = false;
		}
		return false;
	}

	hadleContactUs(event) {
		//redirect to contact page
		window.open(this.hcpDoYouHaveQnsUrl, '_blank');
	}

	handleBackToLogin(event) {
		//redirect to saml login page
		event.preventDefault();
		window.open(this.hcpCountryLoginUrl, '_self');
	}
}