import { LightningElement, track, api } from 'lwc';
export default class ComboBox extends LightningElement {
    @api options = [];
    @api label = "Please Select Options";
    
    @track searchKey = '';
    @track displayOptions = [];
    @track optionsList = "hide";

    // calls after every rendering change
    // renderedCallback(){}

    // initialize component
    connectedCallback() {
        if (this.options.length) {
            this.displayOptions = this.options;
        }
    }
    filterOptions(event) {
        this.openDropDown(event);
        this.searchKey = event.target.value;
        window.clearTimeout(this.delayTimeout);
        
        this.delayTimeout = window.setTimeout(() => {
            this.displayOptions = this.options.filter(word => word.label.toLowerCase().includes(this.searchKey.toLowerCase()));
        }, 500);
    }

    openDropDown(event) {
        event.preventDefault();
        this.optionsList = 'slds-dropdown slds-dropdown_left dropdown_max-width';
    }
    closeDropDown() {
        window.setTimeout(() => {
            this.optionsList = "hide";
        }, 200);
    }

    get isDisplayOptionsPresent() {
        return !this.displayOptions.length;
    }

    selectOption(event) {
        const value = event.currentTarget.getAttribute("data-value");
        const label = event.currentTarget.getAttribute("data-label");
        this.searchKey = label;
        this.closeDropDown();
        this.dispatchEvent(
            new CustomEvent('select', {
                detail: {
                    value: value,
                    label: label
                }
            })
        );
    }
}