import { LightningElement, track, wire } from 'lwc';

export default class SendEmailLWC extends LightningElement {
    @track email;
    @track disabledFlag;
    @track input;

    onChangeEmail(event) {
        
        this.input = this.template.querySelector(".emailInput");
        if(this.input.value.length == 0) {
            this.email = 'efimkopyltoppg@yandex.by';
        }

        if(!this.input.validity.valid) {
            this.disabledFlag = true;
            this.email = null;
        } else if(this.input.validity.valid) {
            this.disabledFlag = false;
            this.email = event.detail.value;
        }
    }
}