import { LightningElement, track, api } from 'lwc';
import sendEmailWithoutTemplate from "@salesforce/apex/examTaskController.sendEmailWithoutTemplate";

export default class SendEmailLWC extends LightningElement {
    @track error;
    @api recordId;

    sendEmailFunc() {
        sendEmailWithoutTemplate({ recordId: this.recordId });
        alert('Email sent.');
    }
}