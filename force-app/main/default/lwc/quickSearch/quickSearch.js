import { LightningElement, wire } from 'lwc';
import getMetaDataOptions from '@salesforce/apex/QuickSearchController.getMetaDataOptions';

export default class QuickSearch extends LightningElement {
    @wire(getMetaDataOptions) metaDataOptions;
    
    renderedCallback() {
        var datalist = this.template.querySelector('datalist');
        var input = this.template.querySelector("input");
        if(datalist && input) {
            if (input.getAttribute("list") === datalist.id) {
                return;
            }
            input.setAttribute("list", datalist.id);
        }
    }
}