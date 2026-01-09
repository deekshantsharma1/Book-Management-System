import { LightningElement, track } from 'lwc';
import searchBooks from '@salesforce/apex/OpenLibraryService.searchBooks';

export default class BookSearch extends LightningElement {

    @track searchKey;

    handleSearchKey(event) {
        this.searchKey = event.target.value;
    }

    handleSearch() {
        searchBooks({ searchKey: this.searchKey })
            .then(result => {
                console.log('Books from API:', result);
                
            })
            .catch(error => {
                console.error('Error:', error);
            });
    }
}
