public with sharing class OpenLibraryService {

    // ---------- WRAPPER FOR SEARCH RESULTS ----------
    public class BookWrapper {
        @AuraEnabled public String title;
        @AuraEnabled public String author;
        @AuraEnabled public String isbn;
        @AuraEnabled public String coverUrl;
        @AuraEnabled public String openLibraryKey; // fallback if no ISBN
    }

    // ---------- SEARCH BOOKS FROM OPEN LIBRARY ----------
    @AuraEnabled(cacheable=true)
    public static List<BookWrapper> searchBooks(String searchKey) {
        List<BookWrapper> results = new List<BookWrapper>();
        if (String.isBlank(searchKey)) return results;

        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setEndpoint(
            'callout:OpenLibrary_Named_Credential/search.json?q=' +
            EncodingUtil.urlEncode(searchKey, 'UTF-8') +
            '&limit=10'
        );

        HttpResponse res = new Http().send(req);

        if(res.getStatusCode() != 200) return results;

        Map<String, Object> response =
            (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

        List<Object> docs = (List<Object>) response.get('docs');

        for (Object obj : docs) {
            Map<String, Object> doc = (Map<String, Object>) obj;

            BookWrapper bw = new BookWrapper();
            bw.title = (String) doc.get('title');
            bw.openLibraryKey = (String) doc.get('key');

            // Author
            if (doc.containsKey('author_name')) {
                List<Object> authors = (List<Object>) doc.get('author_name');
                bw.author = authors.isEmpty() ? null : (String) authors[0];
            }

            // ISBN (use first one if available, else fallback to key)
            if (doc.containsKey('isbn')) {
                List<Object> isbns = (List<Object>) doc.get('isbn');
                bw.isbn = isbns.isEmpty() ? bw.openLibraryKey : (String) isbns[0];
            } else {
                bw.isbn = bw.openLibraryKey;
            }

            // Cover image
            if (doc.containsKey('cover_i')) {
                bw.coverUrl =
                    'https://covers.openlibrary.org/b/id/' +
                    doc.get('cover_i') + '-M.jpg';
            }

            results.add(bw);
        }

        return results;
    }

    // ---------- SAVE BOOK AND ADD TO READING LIST ----------
    @AuraEnabled
    public static void addToReadingList(
        String isbn,
        String title,
        String author,
        String coverUrl
    ) {

        if (String.isBlank(isbn)) {
            throw new AuraHandledException('ISBN or key missing');
        }

        // 1️⃣ Get Contact representing member (simulate Community User)
        Contact member = [
            SELECT Id
            FROM Contact
            WHERE Email = :UserInfo.getUserEmail()
            LIMIT 1
        ];

        // 2️⃣ Upsert Book__c
String isbnValue = isbn;
if (!String.isBlank(isbnValue) && isbnValue.length() > 13) {
    isbnValue = isbnValue.substring(0, 13);
}

Book__c book = new Book__c(
    ISBN__c = isbnValue,
    Title__c = title,
    Author__c = author,
    Cover_Image_URL__c = coverUrl,
    Last_Sync_Date__c = System.now(),
    Is_Available__c = true
);

upsert book ISBN__c;

        // 3️⃣ Prevent duplicates in Reading_List__c
        List<Reading_List__c> existing = [
            SELECT Id
            FROM Reading_List__c
            WHERE Member__c = :member.Id
            AND Book__c = :book.Id
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            throw new AuraHandledException('Book already in reading list');
        }

        // 4️⃣ Create Reading_List__c
        Reading_List__c rl = new Reading_List__c(
            Member__c = member.Id,
            Book__c = book.Id,
            Status__c = 'Want to Read'
        );

        insert rl;
    }
}
