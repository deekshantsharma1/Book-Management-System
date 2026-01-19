public with sharing class OpenLibraryService {

    public class BookWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public String author;
        @AuraEnabled public String isbn;
        @AuraEnabled public String coverUrl;
    }

    @AuraEnabled(cacheable=true)
    public static List<BookWrapper> searchBooks(String searchKey) {

        List<BookWrapper> results = new List<BookWrapper>();
        if (String.isBlank(searchKey)) return results;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:OpenLibrary_Named_Credential/search.json?q=' +
            EncodingUtil.urlEncode(searchKey, 'UTF-8')
        );
        req.setMethod('GET');

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) return results;

        Map<String, Object> body =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> docs = (List<Object>) body.get('docs');

        for (Object o : docs) {
            Map<String, Object> m = (Map<String, Object>) o;

            if (!m.containsKey('isbn')) continue;

            BookWrapper bw = new BookWrapper();
            bw.title = (String) m.get('title');

            List<Object> isbns = (List<Object>) m.get('isbn');
            bw.isbn = (String) isbns[0];

            if (m.containsKey('author_name')) {
                List<Object> authors = (List<Object>) m.get('author_name');
                bw.author = (String) authors[0];
            }

            if (m.containsKey('cover_i')) {
                bw.coverUrl =
                    'https://covers.openlibrary.org/b/id/' +
                    m.get('cover_i') + '-M.jpg';
            }

            results.add(bw);
        }
        return results;
    }

    @AuraEnabled
    public static Id saveBook(String isbn, String title, String author, String coverUrl) {

        if (String.isBlank(isbn))
            throw new AuraHandledException('ISBN missing');

        Book__c book = new Book__c(
            ISBN__c = isbn,
            Title__c = title,
            Author__c = author,
            Cover_Image_URL__c = coverUrl
        );

        upsert book ISBN__c;
        return book.Id;
    }
}
