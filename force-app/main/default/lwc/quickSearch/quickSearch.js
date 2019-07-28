import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMetaDataOptions from '@salesforce/apex/QuickSearchController.getMetaDataOptions';
import getSelectedMetaDataItems from '@salesforce/apex/QuickSearchController.getSelectedMetaDataItems';

export default class QuickSearch extends NavigationMixin(LightningElement) {
    @wire(getMetaDataOptions) metaDataOptions;
    
    @wire(getSelectedMetaDataItems, {
        "selectedMetaDataOption": '$selectedMetaDataOption'
    }) selectedMetaDataItems;
    @track selectedMetaDataOption = '';

    @track selectedMetaDataItem = '';
    url;
    
    renderedCallback() {
        var datalists = this.template.querySelectorAll("datalist");
        if (datalists) {
            datalists.forEach(function(item, index) {
                item.setAttribute("id", index ? "selectedMetaDataItems" : "metaDataOptions");
            });
        }
    }
    
    selectMetaDataOption(event) {
        this.selectedMetaDataOption = event.target.value;
    }
    
    selectMetaDataItem(event) {
        if (this.selectedMetaDataOption === 'apexclass') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: event.target.value,
                    actionName: 'view'
                }
            });
        }
    }

    // navigateToRecordViewPage(event) {
    //     if (this.selectedMetaDataOption === 'apexclass') {
    //         let link = "/lightning/setup/ApexClasses/page?address=/" + event.target.value;
    //         this[NavigationMixin.Navigate]({
    //             type: "standard__webPage",
    //             attributes: {
    //                 "url": link
    //             }
    //         });
    //     //     window.open("/lightning/setup/ApexClasses/page?address=/" + this.selectedMetaDataItem, "_blank");
    //     }
    // }
}