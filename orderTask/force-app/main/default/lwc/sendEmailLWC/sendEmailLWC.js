import { LightningElement, track, wire } from 'lwc';

export default class SendEmailLWC extends LightningElement {
    @track email;

    onChangeEmail(event) {
        this.email = event.detail.value;
    }
}