import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getMetaDataOptions from '@salesforce/apex/QuickSearchController.getMetaDataOptions';
import getSelectedMetaDataItems from '@salesforce/apex/QuickSearchController.getSelectedMetaDataItems';

export default class QuickSearch extends NavigationMixin(LightningElement) {
    @wire(getMetaDataOptions)
    wiredMetaDataOptions({
        error,
        data
    }) {
        if (data) {
            this.metaDataOptions = data;
        } else if (error) {
            this.metaDataOptions = [];
        }
    }
    
    @wire(getSelectedMetaDataItems, {
        "selectedMetaDataOption": '$selectedMetaDataOption'
    })
    wiredMetaDataItems({
        error,
        data
    }) {
        if (data) {
            this.selectedMetaDataItems = [];
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            window.setTimeout(() => {
                this.selectedMetaDataItems = data;
            }, 200);
        } else if (error) {
            this.selectedMetaDataItems = [];
        }
    }

    @track metaDataOptions = [];
    @track selectedMetaDataItems = [];
    @track selectedMetaDataOption = '';
    
    selectMetaData(event) {
        this.selectedMetaDataOption = event.detail.value;
    }
    
    selectMetaDataItem(event) {
        var sourceList = [];
        if (sourceList.includes(this.selectedMetaDataOption)) {
            // TODO navigate using NavigationMixin
        } else {
            let urlToNavigate = event.detail.value;
            this.navigateToRecordViewPage(undefined, urlToNavigate);
        }
    }

    navigateToRecordViewPage(pageReference, urlToNavigate) {
        if (urlToNavigate) {
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