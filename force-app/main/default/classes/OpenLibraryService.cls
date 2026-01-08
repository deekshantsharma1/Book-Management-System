public with sharing class OpenLibraryService {

    // Wrapper class for search results
    public class BookWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public String authorName;
        @AuraEnabled public String isbn;
        @AuraEnabled public Integer firstPublishYear;
        @AuraEnabled public String coverUrl;
    }

    @AuraEnabled(cacheable=true)
    public static List<BookWrapper> searchBooks(String searchKey) {

        List<BookWrapper> bookList = new List<BookWrapper>();

        if (String.isBlank(searchKey)) {
            return bookList;
        }

        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();

            String endpoint =
                'https://openlibrary.org/search.json?q=' +
                EncodingUtil.urlEncode(searchKey, 'UTF-8');

            request.setEndpoint(endpoint);
            request.setMethod('GET');

            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {

                Map<String, Object> responseMap =
                    (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

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
                        bw.firstPublishYear =
                            (Integer) doc.get('first_publish_year');
                    }

                    // Cover Image
                    if (doc.containsKey('cover_i')) {
                        bw.coverUrl =
                            'https://covers.openlibrary.org/b/id/' +
                            String.valueOf(doc.get('cover_i')) +
                            '-M.jpg';
                    }

                    bookList.add(bw);
                }
            }
        } catch (Exception e) {
            System.debug('Error while fetching books: ' + e.getMessage());
        }

        return bookList;
    }
}
