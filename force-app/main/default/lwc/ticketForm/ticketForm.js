import { LightningElement, track } from 'lwc';
import createTicket from '@salesforce/apex/TicketController.createTicket';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TicketForm extends LightningElement {

    @track subject = '';
    @track description = '';
    @track priority = 'Medium';

    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' }
    ];

    handleChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleSubmit() {
        createTicket({
            subject: this.subject,
            description: this.description,
            priority: this.priority,
            contactId: null
        })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Ticket Created Successfully',
                    variant: 'success'
                })
            );
            this.subject = '';
            this.description = '';
            this.priority = 'Medium';
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }
}
