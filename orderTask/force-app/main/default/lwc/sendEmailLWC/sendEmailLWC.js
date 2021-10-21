import { LightningElement, api } from 'lwc';
import sendEmailWithTemplate from "@salesforce/apex/ExamTaskController.sendEmailWithTemplate";

export default class SendEmailLWC extends LightningElement {
    @api recordId;

    showStatus = false;

    sendEmailFunc() {
        sendEmailWithTemplate({ recordId: this.recordId });
        this.showStatus = true;
        setTimeout(() => {
            this.showStatus = false;
        }, 5500);
    }

    get emailSentStatus() {
        return this.showStatus ? 'emailStatus' : 'hideEmailStatus';
    }
}