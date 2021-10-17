import { LightningElement, api } from 'lwc';
import sendEmailWithTemplate from "@salesforce/apex/ExamTaskController.sendEmailWithTemplate";

export default class SendEmailLWC extends LightningElement {
    @api recordId;

    sendEmailFunc() {
        sendEmailWithTemplate({ recordId: this.recordId });
        alert('Email sent.');
    }
}