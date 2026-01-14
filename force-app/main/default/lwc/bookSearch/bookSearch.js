import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';

export default class BookSearch extends LightningElement {

    @track searchKey = '';
    @track books = [];
    @track isLoading = false;

    handleSearchKey(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        if (!this.searchKey) {
            return;
        }

        this.isLoading = true;

        searchBooks({ searchKey: this.searchKey })
            .then(result => {
                this.books = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching books', error);
                this.isLoading = false;
            });
    }

    get hasBooks() {
        return this.books && this.books.length > 0;
    }
}
