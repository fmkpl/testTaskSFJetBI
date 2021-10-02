import { LightningElement, wire, track } from 'lwc';
import getAllAccountNamesWithOrders from '@salesforce/apex/examTaskController.getAllAccountNamesWithOrders';
import getAllMonthsOfPaymentDueDate from '@salesforce/apex/examTaskController.getAllMonthsOfPaymentDueDate';
let i = 0;

export default class ExamTaskLWC extends LightningElement {
    accountName = '';
    valueMonth = '';

    @track errorNames;
    @track accNames = [];

    @track errorMonths;
    @track monthNames = [];

    get accountNamesOptions() {
        return this.accNames;
    }

    @wire(getAllAccountNamesWithOrders)
    wiredNames({error, data}) {
        if(data) {
            this.accNames = [];
            for(i = 0; i < data.length; i++) {
                this.accNames = [...this.accNames, {value: data[i], label: data[i]}]; 
            }
            error = undefined;
        } else if(error) {
            this.errorNames = error;
            this.accNames = undefined;
        }
    }

    handleChange(event) {
        this.accountName = event.detail.value;
    }

    get monthNamesOptions() {
        return this.monthNames;
    }

    @wire(getAllMonthsOfPaymentDueDate, { accountName: '$accountName'})
    wiredMonths({error, data}) {
        if(data) {
            this.monthNames = [];
            for(i = 0; i < data.length; i++) {
                this.monthNames = [...this.monthNames, {value: data[i], label: data[i]}]; 
            }
            error = undefined;
        } else if(error) {
            this.errorMonths = error;
            this.monthNames = undefined;
        }
    }

    handleChangeMonth(event) {
        this.valueMonth = event.detail.value;
    }
}