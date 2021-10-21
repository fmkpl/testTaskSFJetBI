import { LightningElement, wire, track } from 'lwc';
import getAllAccountNamesWithOrders from '@salesforce/apex/ExamTaskController.getAllAccountNamesWithOrders';
import getAllMonthsOfPaymentDueDate from '@salesforce/apex/ExamTaskController.getAllMonthsOfPaymentDueDate';
import getOrders from '@salesforce/apex/ExamTaskController.getOrders';
let i = 0;

export default class ExamTaskLWC extends LightningElement {
    //VARIABLES
    @track accountName = '';
    @track valueMonth = '';

    errorAccNames;
    accNames = [];

    errorMonthsNames;
    monthNames = [];

    orders = [];
    errorOrders;

    columns = [
        {
            label: 'Order name',
            fieldName: 'nameUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Payment Due Date',
            fieldName: 'Payment_Due_date__c'
        },
        {
            label: 'Total sum, $',
            fieldName: 'Total_Amount__c'
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
            this.errorAccNames = error;
            this.accNames = undefined;
        }
    }

    handleChangeAccName(event) {
        this.accountName = event.detail.value;
        this.valueMonth = '';
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
            this.errorMonthsNames = error;
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

    //STYLE WORK
    get classToShowAccName() {
        return this.accountName != '' ? 'showAccName' : 'hideAccName';
    }

    get classToShowMonthName() {
        return this.valueMonth != '' ? 'showMonthName' : 'hideMonthName'; 
    }

    get classToShowTable() {
        return (this.valueMonth != '' & this.accountName != '') ? 'showTable' : 'hideTable';
    }
}