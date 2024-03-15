import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import validationSuccessUrl from '@salesforce/label/c.HCPEmailvalidationSuccessUrl';
import updateContactRecord from '@salesforce/apex/EmailVerificationController.updateContactRecord';

export default class EmailVerification extends NavigationMixin(LightningElement) {
    // Expose the labels to use in the template.
     label = {
        validationSuccessUrl,
    };

    
    @track error;
    @track errorCodeValue;
    @track emailKeyValue;
    connectedCallback() {
        const param = 'key';
        this.emailKeyValue = this.getUrlParamValue(window.location.href, param);
        if(this.emailKeyValue != null){
            this.CallApexFunction();
        }
    }
    
    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    async CallApexFunction(){ 
        try {
            this.errorCodeValue = await updateContactRecord({emailVerificationKey:this.emailKeyValue});
            console.log(this.errorCodeValue);
        } catch (error) {
            console.log(error);
        }
        this.handleNavigate();
    }

    // Navigate to external page
      handleNavigate() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: ''
            }
        }).then(url => {
            window.open(validationSuccessUrl + this.errorCodeValue, "_self");
        });
    }
   
}