import { LightningElement, track, api } from 'lwc';

export default class ComboBox extends LightningElement {
    @api options = [];
    @api label = "Please Select Options";
    @track displayOptions = [];

    renderedCallback() {
        this.displayOptions = this.options;
    }
    selectOption(event) {
        let value = event.target.value;
        if (value && Array.isArray(this.options)) {
            this.displayOptions = this.options.filter(word => word.includes(value));
        }
    }
}