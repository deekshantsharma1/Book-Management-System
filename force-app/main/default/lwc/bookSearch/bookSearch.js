import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';
import saveBook from '@salesforce/apex/OpenLibraryService.saveBook';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BookSearch extends LightningElement {
    searchKey = '';
    @track books = [];

    handleChange(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        searchBooks({ searchKey: this.searchKey })
            .then(result => {
                this.books = result;
            })
            .catch(error => {
                this.showToast(
                    'Error',
                    error?.body?.message || 'Search failed',
                    'error'
                );
            });
    }

    handleSave(event) {
        const book = event.detail;

        let isbnValue = '';

        // ✅ Case 1: Valid ISBN (<= 13 chars)
        if (book.isbn && book.isbn.length <= 13) {
            isbnValue = book.isbn;
        }
        // ✅ Case 2: No ISBN → generate safe 13-char fallback
        else if (book.key) {
            isbnValue = book.key
                .replace('/works/', '')   // remove prefix
                .replace(/\//g, '')       // remove slashes
                .substring(0, 13);        // HARD LIMIT
        }

        saveBook({
            isbn: isbnValue,
            title: book.title,
            author: book.author,
            coverUrl: book.coverUrl
        })
            .then(() => {
                this.showToast(
                    'Success',
                    'Book added to library',
                    'success'
                );
            })
            .catch(error => {
                this.showToast(
                    'Error',
                    error?.body?.message || 'Save failed',
                    'error'
                );
            });
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
