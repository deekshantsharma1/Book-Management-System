import { LightningElement, api } from 'lwc';
import submitReview from '@salesforce/apex/MemberReviewService.submitReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookReview extends LightningElement {
    @api bookId;

    rating;
    reviewTitle = '';
    reviewBody = '';

    ratingOptions = [
        { label: '1 Star', value: 1 },
        { label: '2 Stars', value: 2 },
        { label: '3 Stars', value: 3 },
        { label: '4 Stars', value: 4 },
        { label: '5 Stars', value: 5 }
    ];

    handleRatingChange(event) {
        this.rating = parseInt(event.detail.value, 10);
    }

    handleTitleChange(event) {
        this.reviewTitle = event.target.value;
    }

    handleBodyChange(event) {
        this.reviewBody = event.target.value;
    }

    handleSubmit() {
        if (!this.bookId) {
            this.showToast('Error', 'Book not found', 'error');
            return;
        }

        submitReview({
            bookId: this.bookId,
            rating: this.rating,
            reviewTitle: this.reviewTitle,
            reviewBody: this.reviewBody
        })
        .then(() => {
            this.showToast('Success', 'Review submitted successfully', 'success');
            this.resetForm();
        })
        .catch(error => {
            this.showToast(
                'Error',
                error.body?.message || 'Failed to submit review',
                'error'
            );
        });
    }

    resetForm() {
        this.rating = null;
        this.reviewTitle = '';
        this.reviewBody = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
