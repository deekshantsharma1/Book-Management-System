import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';
import saveBook from '@salesforce/apex/OpenLibraryService.saveBook';
import addToLibrary from '@salesforce/apex/ReadingListService.addToLibrary';

export default class BookSearch extends LightningElement {

    searchKey = '';
    @track books = [];

    contactId = 'PUT_CONTACT_ID_HERE'; // TEMP

    handleChange(e) {
        this.searchKey = e.target.value;
    }

    handleSearch() {
        searchBooks({ searchKey: this.searchKey })
            .then(r => this.books = r);
    }

    handleAdd(e) {
        const book = e.target.dataset.book;

        saveBook(book)
            .then(bookId => {
                return addToLibrary({
                    bookId: bookId,
                    contactId: this.contactId
                });
            });
    }
}
