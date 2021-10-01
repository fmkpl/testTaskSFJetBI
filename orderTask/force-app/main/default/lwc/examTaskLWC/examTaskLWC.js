import { LightningElement, wire, track } from 'lwc';
import getAllAccountNamesWithOrders from '@salesforce/apex/examTaskController.getAllAccountNamesWithOrders';
let i = 0;

export default class ExamTaskLWC extends LightningElement {
    value='';
    @track error;
    @track items = [];

    get accountNamesOptions() {
        return this.items;
    }

    @wire(getAllAccountNamesWithOrders)
    wiredNames({error, data}) {
        if(data) {
            for(i = 0; i < data.length; i++) {
                this.items = [...this.items, {value: data[i], label: data[i]}]; 
            }
            error = undefined;
        } else if(error) {
            this.error = error;
            this.names = undefined;
        }
    }

    handleChange(event) {
        this.value = event.detail.value;
    }
}