import { LightningElement, wire, track } from 'lwc';
import getMyLibrary from '@salesforce/apex/ReadingListService.getMyLibrary';

export default class MyLibrary extends LightningElement {

    contactId = 'PUT_CONTACT_ID_HERE'; // TEMP
    @track records;

    @wire(getMyLibrary, { contactId: '$contactId' })
    wiredData({ data }) {
        if (data) this.records = data;
    }
}
