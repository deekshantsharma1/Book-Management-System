import { LightningElement, wire } from 'lwc';
import getRecommendedBooks from
    '@salesforce/apex/BookRecommendationService.getRecommendedBooks';

export default class RecommendedBooks extends LightningElement {

    recommendedBooks = [];
    error;

    @wire(getRecommendedBooks)
    wiredRecommendations({ data, error }) {
        if (data) {
            this.recommendedBooks = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.recommendedBooks = [];
            console.error('Recommendation error', error);
        }
    }

    get hasRecommendations() {
        return this.recommendedBooks && this.recommendedBooks.length > 0;
    }

    get showEmptyState() {
        return this.recommendedBooks && this.recommendedBooks.length === 0;
    }
}
