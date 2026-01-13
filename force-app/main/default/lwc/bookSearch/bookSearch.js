import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';

export default class BookSearch extends LightningElement {

    @track searchKey;
    @track books = [];

    handleSearchKey(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        searchBooks({ searchKey: this.searchKey })
            .then(result => {
                this.books = result;
                console.log('Stored books:', this.books);
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }

    get hasBooks() {
        return this.books && this.books.length > 0;
    }
}
