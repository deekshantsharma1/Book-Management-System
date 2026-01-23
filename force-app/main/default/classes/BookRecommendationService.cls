public with sharing class BookRecommendationService {

    @AuraEnabled(cacheable=true)
    public static List<Book__c> getRecommendedBooks() {

        String userEmail = UserInfo.getUserEmail();

        Contact member = [
            SELECT Id
            FROM Contact
            WHERE Email = :userEmail
            LIMIT 1
        ];

        List<Reading_List__c> readingList = [
            SELECT Book__c, Book__r.Genre__c
            FROM Reading_List__c
            WHERE Member__c = :member.Id
        ];

        if (readingList.isEmpty()) {
            return new List<Book__c>();
        }

        Set<Id> readBookIds = new Set<Id>();
        Set<String> genreSet = new Set<String>();

        for (Reading_List__c rl : readingList) {
            readBookIds.add(rl.Book__c);

            if (rl.Book__r.Genre__c != null) {
                for (String g : rl.Book__r.Genre__c.split(';')) {
                    genreSet.add(g.trim());
                }
            }
        }

        if (genreSet.isEmpty()) {
            return new List<Book__c>();
        }

        // 🔥 Build dynamic WHERE clause
        List<String> genreConditions = new List<String>();
        for (String g : genreSet) {
            genreConditions.add('Genre__c INCLUDES (\'' + String.escapeSingleQuotes(g) + '\')');
        }

        String soql =
            'SELECT Id, Title__c, Author__c, Genre__c, Average_Rating__c, Cover_Image_URL__c ' +
            'FROM Book__c ' +
            'WHERE (' + String.join(genreConditions, ' OR ') + ') ' +
            'AND Id NOT IN :readBookIds ' +
            'ORDER BY Average_Rating__c DESC NULLS LAST ' +
            'LIMIT 10';

        return Database.query(soql);
    }
}
