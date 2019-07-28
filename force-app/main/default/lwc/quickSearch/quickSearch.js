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
    // @track recordId = '';
    // @track objectApiName = '';
    // @track navigationUrl = '';
    // pageReference;

    renderedCallback() {
        // let datalists = this.template.querySelectorAll("datalist");
        // let inputElements = this.template.querySelectorAll('input');
        // if (datalists) {
        //     datalists.forEach(function(item, index) {
        //         item.setAttribute("id", index ? "selectedMetaDataItems" : "metaDataOptions");
        //     });
        // }
        // if (inputElements) {
        //     inputElements.forEach(function (item) {
        //         item.addEventListener('input', function () {
        //             var value = this.value;
        //             var opt = [].find.call(this.list.options, function (option) {
        //                 return option.value === value;
        //             });
        //             if (opt) {
        //                 this.value = opt.label;
        //             }
        //         });
        //     });
        // }
    }
    
    selectMetaDataOption(event) {
        this.selectedMetaDataOption = event.target.value;
    }
    
    selectMetaDataItem(event) {
        if (this.selectedMetaDataOption === 'apexclass') {
            // this.recordId = event.target.value;
            // this.objectApiName = "ApexClass";
            // this[NavigationMixin.Navigate](this.pageReference);
            let urlToNavigate = "/lightning/setup/ApexClasses/page?address=/" + event.target.value;
            this.navigateToRecordViewPage(undefined, urlToNavigate);
        }
    }

    navigateToRecordViewPage(pageReference, urlToNavigate) {
        if (urlToNavigate) {
            // this[NavigationMixin.GenerateUrl](pageReference).then(function(url) {
            //     urlToNavigate = url;
            // });
            window.open(urlToNavigate, "_blank");
        } else {
            this[NavigationMixin.Navigate](pageReference);
        }
    }
    // connectedCallback() {
    //     this.pageReference = {
    //         type: "standard__recordPage",
    //         attributes: {
    //             "recordId": this.recordId,
    //             "objectApiName": this.objectApiName,
    //             "actionName": "view"
    //         }
    //     };
    //     this[NavigationMixin.GenerateUrl](this.pageReference).then(function (url) {
    //         this.navigationUrl = url;
    //     });
    // }
}