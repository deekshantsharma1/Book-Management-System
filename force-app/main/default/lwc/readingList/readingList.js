import { LightningElement, track, wire } from 'lwc';
import getMemberReadingList from '@salesforce/apex/ReadingTrackingService.getMemberReadingList';
import updateReadingProgress from '@salesforce/apex/ReadingTrackingService.updateReadingProgress';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReadingList extends LightningElement {
    @track readingList = [];

    // Status picklist options
    statusOptions = [
        { label: 'Want to Read', value: 'Want to Read' },
        { label: 'Currently Reading', value: 'Currently Reading' },
        { label: 'Finished', value: 'Finished' }
    ];

    @wire(getMemberReadingList)
    wiredReadingList({ error, data }) {
        if (data) {
            this.readingList = data;
        } else if (error) {
            this.showToast('Error', error.body.message || 'Failed to fetch reading list', 'error');
        }
    }

    handlePageChange(event) {
        const rlId = event.target.dataset.id;
        const currentPage = parseInt(event.target.value, 10);
        this.updateReadingList(rlId, currentPage, null);
    }

    handleStatusChange(event) {
        const rlId = event.target.dataset.id;
        const status = event.target.value;
        this.updateReadingList(rlId, null, status);
    }

    updateReadingList(rlId, currentPage, status) {
        updateReadingProgress({ readingListId: rlId, currentPage: currentPage, status: status })
            .then(() => {
                this.showToast('Success', 'Reading progress updated', 'success');
                // Refresh the list
                return getMemberReadingList();
            })
            .then(data => {
                this.readingList = data;
            })
            .catch(error => {
                this.showToast('Error', error.body.message || 'Update failed', 'error');
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
    get noBooksToDisplay() {
        return this.readingList && this.readingList.length === 0;
    }
}
