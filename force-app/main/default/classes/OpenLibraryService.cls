public with sharing class OpenLibraryService {

    // Wrapper class to send data to LWC
    public class BookWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public String authorName;
        @AuraEnabled public String isbn;
        @AuraEnabled public Integer publishYear;
        @AuraEnabled public String coverUrl;
    }

    @AuraEnabled(cacheable=true)
    public static List<BookWrapper> searchBooks(String searchKey) {

        List<BookWrapper> results = new List<BookWrapper>();

        if (String.isBlank(searchKey)) {
            return results;
        }

        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();

            // Named Credential usage
            String endpoint =
                'callout:OpenLibrary_Named_Credential/search.json?q=' +
                EncodingUtil.urlEncode(searchKey, 'UTF-8');

            req.setEndpoint(endpoint);
            req.setMethod('GET');

            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {

                Map<String, Object> responseMap =
                    (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                List<Object> docs = (List<Object>) responseMap.get('docs');

                for (Object obj : docs) {
                    Map<String, Object> doc = (Map<String, Object>) obj;

                    BookWrapper bw = new BookWrapper();

                    bw.title = (String) doc.get('title');

                    // Author
                    if (doc.containsKey('author_name')) {
                        List<Object> authors = (List<Object>) doc.get('author_name');
                        if (!authors.isEmpty()) {
                            bw.authorName = String.valueOf(authors[0]);
                        }
                    }

                    // ISBN
                    if (doc.containsKey('isbn')) {
                        List<Object> isbns = (List<Object>) doc.get('isbn');
                        if (!isbns.isEmpty()) {
                            bw.isbn = String.valueOf(isbns[0]);
                        }
                    }

                    // Publish Year
                    if (doc.containsKey('first_publish_year')) {
                        bw.publishYear =
                            (Integer) doc.get('first_publish_year');
                    }

                    // Cover Image
                    if (doc.containsKey('cover_i')) {
                        bw.coverUrl =
                            'https://covers.openlibrary.org/b/id/' +
                            String.valueOf(doc.get('cover_i')) +
                            '-M.jpg';
                    }

                    results.add(bw);
                }
            }
        } catch (Exception e) {
            System.debug('OpenLibrary API Error: ' + e.getMessage());
        }

        return results;
    }
}
