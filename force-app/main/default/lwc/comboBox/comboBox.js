import { LightningElement, track, api } from 'lwc';
export default class ComboBox extends LightningElement {
    @api options = [];
    @api label = "Please Select Options";
    
    @track searchKey = '';
    @track displayOptions;

    renderedCallback() {
        if (!this.displayOptions) {
            this.displayOptions = this.options;
        }
    }
    filterOptions(event) {
        this.searchKey = event.target.value;
        window.clearTimeout(this.delayTimeout);
        
        this.delayTimeout = window.setTimeout(() => {
            this.displayOptions = this.options.filter(word => word.label.toLowerCase().includes(this.searchKey.toLowerCase()));
        }, 500);
    }
}