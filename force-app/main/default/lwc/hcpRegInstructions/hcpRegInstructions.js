import { LightningElement, api } from 'lwc';
import HCPHEADER from '@salesforce/label/c.HCPHeader';
import HCPORDERLISTHEADING from '@salesforce/label/c.HCPOrderListHeading';
import HCPINSTRCUTIONSARRAY from '@salesforce/label/c.HCPInstrcutionsArray';
import HCPACCOUNTCREATETEXT from '@salesforce/label/c.HCPAccountCreateText';
import HCPREGISTERTEXT from '@salesforce/label/c.HCPRegisterText';


export default class HcpRegInstructions extends LightningElement {
    header =  HCPHEADER;
    orderedListSubHead = HCPORDERLISTHEADING;
    instructionsArrayText = HCPINSTRCUTIONSARRAY;
    createAccountText = HCPACCOUNTCREATETEXT;
    registerText = HCPREGISTERTEXT;
    instructionsArray;
    connectedCallback() {
        if(this.instructionsArrayText) {
            this.instructionsArray = JSON.parse(this.instructionsArrayText);
        }
    }
}