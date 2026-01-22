import { LightningElement, api, track, wire } from 'lwc';
import getReviews from '@salesforce/apex/MemberReviewService.getReviews';
import submitReview from '@salesforce/apex/MemberReviewService.submitReview';
import upvoteReview from '@salesforce/apex/MemberReviewService.upvoteReview';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ReviewList extends LightningElement {
    @api recordId; // Book__c Id from record page
    @track reviews = [];
    @track reviewTitle = '';
    @track reviewBody = '';
    @track rating;
    @track showReviewForm = true;

    get ratingOptions() {
        return [
            { label: '1', value: 1 },
            { label: '2', value: 2 },
            { label: '3', value: 3 },
            { label: '4', value: 4 },
            { label: '5', value: 5 }
        ];
    }

    get noReviews() {
        return !this.reviews || this.reviews.length === 0;
    }

    // Fetch reviews on load or after actions
    connectedCallback() {
        this.loadReviews();
    }

    loadReviews() {
        getReviews({ bookId: this.recordId })
            .then(result => {
                this.reviews = result;
            })
            .catch(error => {
                this.showToast('Error loading reviews', error.body.message, 'error');
            });
    }

    // Handle input changes
    handleTitleChange(event) { this.reviewTitle = event.target.value; }
    handleBodyChange(event) { this.reviewBody = event.target.value; }
    handleRatingChange(event) { this.rating = event.detail.value; }

    // Submit review
    submitReview() {
        if (!this.reviewTitle || !this.reviewBody || !this.rating) {
            this.showToast('Error', 'Please complete all fields', 'error');
            return;
        }

        submitReview({
            bookId: this.recordId,
            reviewTitle: this.reviewTitle,
            reviewBody: this.reviewBody,
            rating: parseInt(this.rating)
        })
        .then(() => {
            this.showToast('Success', 'Review submitted!', 'success');
            this.reviewTitle = '';
            this.reviewBody = '';
            this.rating = null;
            this.loadReviews();
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    // Upvote review
    handleUpvote(event) {
        const reviewId = event.target.dataset.id;
        upvoteReview({ reviewId })
            .then(() => {
                this.showToast('Success', 'Review upvoted!', 'success');
                this.loadReviews();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Toast helper
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
