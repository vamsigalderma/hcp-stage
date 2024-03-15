import { LightningElement } from 'lwc';
import updateUserRecord from '@salesforce/apex/HCPUserManagement.getLoginUrl';

export default class LwcHcpGeneralHomeComponent extends LightningElement {
    connectedCallback() {
        updateUserRecord()
            .then((result) => {
                window.open(result, '_self');
            })
            .catch((error) => {
                window.open('gainconnect.com', '_self');
            });
    }
}