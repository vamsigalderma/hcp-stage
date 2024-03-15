import { LightningElement, wire } from 'lwc';
import updateUserRecord from '@salesforce/apex/HCPUserManagement.updateUserRecord';
import HCpCountryLoginUrl from '@salesforce/label/c.HCpCountryLoginUrl';

export default class LwcHcpHomeComponent extends LightningElement {

    loginUrl = HCpCountryLoginUrl;
    connectedCallback() {
        updateUserRecord()
            .then((result) => {
                this.redirect();
            })
            .catch((error) => {
                this.redirect();
            });
    }

    redirect(){
        window.open(this.loginUrl, '_self');
    }

}