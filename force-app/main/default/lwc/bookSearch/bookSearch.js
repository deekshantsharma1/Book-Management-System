import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';
import addToReadingList from '@salesforce/apex/OpenLibraryService.addToReadingList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookSearch extends LightningElement {
    @track searchKey = '';
    @track books = [];

    // Getter for "No books to display"
    get noBooksToDisplay() {
        return this.books && this.books.length === 0;
    }

    handleChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (!this.searchKey) {
            this.showToast('Warning', 'Please enter a search term', 'warning');
            return;
        }

        searchBooks({ searchKey: this.searchKey })
            .then(result => {
                this.books = result;
                if (!result || result.length === 0) {
                    this.showToast('Info', 'No books found', 'info');
                }
            })
            .catch(error => {
                this.showToast('Error', error?.body?.message || 'Search failed', 'error');
            });
    }

    handleAdd(event) {
        const index = event.currentTarget.dataset.index;
        const book = this.books[index];

        addToReadingList({
            isbn: book.isbn,
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl
        })
        .then(() => {
            this.showToast('Success', 'Book added to reading list', 'success');
        })
        .catch(error => {
            this.showToast('Error', error?.body?.message || 'Add failed', 'error');
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
