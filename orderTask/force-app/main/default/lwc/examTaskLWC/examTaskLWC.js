import { LightningElement, wire, track } from 'lwc';
import getAllAccountNamesWithOrders from '@salesforce/apex/examTaskController.getAllAccountNamesWithOrders';
import getAllMonthsOfPaymentDueDate from '@salesforce/apex/examTaskController.getAllMonthsOfPaymentDueDate';
import getOrders from '@salesforce/apex/examTaskController.getOrders';
let i = 0;

export default class ExamTaskLWC extends LightningElement {
    //VARIABLES
    accountName = '';
    valueMonth = '';

    @track errorNames;
    @track accNames = [];

    @track errorMonths;
    @track monthNames = [];

    @track orders = [];
    @track errorOrders;
    @track columns = [
        {
            label: 'Order name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true
        }
    ];

    //GET ACCOUNT NAMES
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

    //GET MONTHS FROM ORDERS RELATED TO ACCOUNTS
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

    //GET ORDER RECORDS
    @wire(getOrders, { accountName: '$accountName', valueMonth: '$valueMonth' })
    wiredOpps(result) {
        const { data, error } = result;
        if(data) {
            let nameUrl;
            this.orders = data.map(row => { 
                nameUrl = `/${row.Id}`;
                return {...row , nameUrl} 
            })
            this.errorOrders = null;
        }
        if(error) {
            this.errorOrders = error;
            this.orders = [];
        }
    }
}