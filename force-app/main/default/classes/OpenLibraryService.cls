public with sharing class OpenLibraryService {

    // ---------- WRAPPER ----------
    public class BookWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public String author;
        @AuraEnabled public String isbn;
        @AuraEnabled public String coverUrl;
        @AuraEnabled public String key; // OpenLibrary unique key
    }

    // ---------- SEARCH BOOKS ----------
    @AuraEnabled(cacheable=true)
    public static List<BookWrapper> searchBooks(String searchKey) {

        List<BookWrapper> results = new List<BookWrapper>();

        if (String.isBlank(searchKey)) {
            return results;
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            'callout:OpenLibrary_Named_Credential/search.json?q=' +
            EncodingUtil.urlEncode(searchKey, 'UTF-8')
        );
        req.setMethod('GET');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> response =
                (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            List<Object> docs = (List<Object>) response.get('docs');

            for (Object obj : docs) {
                Map<String, Object> bookMap = (Map<String, Object>) obj;

                BookWrapper bw = new BookWrapper();
                bw.title = (String) bookMap.get('title');
                bw.key   = (String) bookMap.get('key'); // ⭐ important

                if (bookMap.containsKey('author_name')) {
                    List<Object> authors =
                        (List<Object>) bookMap.get('author_name');
                    bw.author = authors.isEmpty() ? '' : (String) authors[0];
                }

                if (bookMap.containsKey('isbn')) {
                    List<Object> isbns =
                        (List<Object>) bookMap.get('isbn');
                    bw.isbn = isbns.isEmpty() ? null : (String) isbns[0];
                }

                if (bookMap.containsKey('cover_i')) {
                    bw.coverUrl =
                        'https://covers.openlibrary.org/b/id/' +
                        bookMap.get('cover_i') + '-M.jpg';
                }

                results.add(bw);
            }
        }

        return results;
    }

    // ---------- SAVE BOOK ----------
    @AuraEnabled
    public static String saveBook(
        String isbn,
        String title,
        String author,
        String coverUrl
    ) {
        try {
            if (String.isBlank(isbn)) {
                throw new AuraHandledException(
                    'Unique Book Identifier is missing'
                );
            }

            Book__c book = new Book__c(
                ISBN__c = isbn,
                Title__c = title,
                Author__c = author,
                Cover_Image_URL__c = coverUrl
            );

            upsert book ISBN__c;
            return 'SUCCESS';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
