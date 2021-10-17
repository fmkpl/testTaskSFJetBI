import { LightningElement, api } from 'lwc';
import sendEmailWithoutTemplate from "@salesforce/apex/ExamTaskController.sendEmailWithoutTemplate";

export default class SendEmailLWC extends LightningElement {
    @api recordId;

    sendEmailFunc() {
        sendEmailWithoutTemplate({ recordId: this.recordId });
        alert('Email sent.');
    }
}