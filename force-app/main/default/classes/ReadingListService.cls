public with sharing class ReadingListService {

    @AuraEnabled
    public static void addToLibrary(Id bookId, Id contactId) {

        Reading_List__c rl = new Reading_List__c(
            Book__c = bookId,
            Member__c = contactId,
            Status__c = 'Want to Read'
        );
        insert rl;
    }

    @AuraEnabled(cacheable=true)
    public static List<Reading_List__c> getMyLibrary(Id contactId) {

        return [
            SELECT Id, Status__c,
                   Book__r.Title__c,
                   Book__r.Author__c,
                   Book__r.Cover_Image_URL__c
            FROM Reading_List__c
            WHERE Member__c = :contactId
            ORDER BY CreatedDate DESC
        ];
    }
}
