import { LightningElement, api } from 'lwc';

export default class BookSearchResult extends LightningElement {
    @api book;

    handleSave() {
        this.dispatchEvent(
            new CustomEvent('savebook', {
                detail: this.book
            })
        );
    }
}
