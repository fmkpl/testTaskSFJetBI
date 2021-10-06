import { LightningElement, track, wire } from 'lwc';
import getEmailOfCurrentUser from '@salesforce/apex/examTaskController.getEmailOfCurrentUser';
import sendEmailWithoutTemplate from "@salesforce/apex/examTaskController.sendEmailWithoutTemplate";

export default class SendEmailLWC extends LightningElement {
    @track email;
    @track disabledFlag;
    @track input;
    @track error;
    staticEmail;

    onChangeEmail(event) {
        this.input = this.template.querySelector(".emailInput");

        if(!this.input.validity.valid) {
            this.disabledFlag = true;
            this.email = null;
        } else if(this.input.validity.valid) {
            this.disabledFlag = false;
            this.email = event.detail.value;
        }
    }

    sendEmailFunc() {
        if(this.email == '') {
            this.email = this.staticEmail;
        }

        sendEmailWithoutTemplate({email: this.email});
    }

    @wire(getEmailOfCurrentUser)
    wiredEmail({data, error}) {
        if(data) {
            this.email = data;
            this.staticEmail = data;
            error = undefined;
        } else if(error) {
            this.error = error;
            this.email = undefined;
        }
    }
}