import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import GALDERMA_LOGO from '@salesforce/resourceUrl/GALDERMA_LOGO';

export default class NavigationMenuLogo extends NavigationMixin(
    LightningElement
) {
    @api formfactor;
    @api page;

    /**
     * the azInsuranceLogo (NavigationMenu Logo) pulled from static resources
     */

    @api
    set logo(value) {
        this.azInsuranceLogo = value;
    }

    get logo() {
        return this.formfactor === 'hamburger' ? GALDERMA_LOGO : GALDERMA_LOGO;
    }

    _azInsuranceLogo;

    handleClick(evt) {
        // use the NavigationMixin from lightning/navigation to perform the navigation.
        // prevent default anchor link since lightning navigation will be handling the click
        evt.stopPropagation();
        evt.preventDefault();
        // Navigate to the home page
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}