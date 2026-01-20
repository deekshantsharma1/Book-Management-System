public with sharing class ReadingTrackingService {

    // Get all Reading_List__c records for current member
    @AuraEnabled(cacheable=true)
    public static List<Reading_List__c> getMemberReadingList() {
        Contact member = [
            SELECT Id 
            FROM Contact 
            WHERE Email = :UserInfo.getUserEmail() 
            LIMIT 1
        ];

        return [
            SELECT Id, Current_Page__c, Status__c, Finish_Date__c,
                   Book__r.Title__c, Book__r.Author__c, Book__r.Cover_Image_URL__c
            FROM Reading_List__c
            WHERE Member__c = :member.Id
        ];
    }

    // Update reading progress: current page, status, finish date
    @AuraEnabled
    public static Reading_List__c updateReadingProgress(
        Id readingListId,
        Integer currentPage,
        String status
    ) {
        if (readingListId == null) {
            throw new AuraHandledException('Reading List Id is required');
        }

        Reading_List__c rl = [
            SELECT Id, Status__c, Current_Page__c, Finish_Date__c
            FROM Reading_List__c
            WHERE Id = :readingListId
            LIMIT 1
        ];

        // Update current page
        if (currentPage != null) {
            rl.Current_Page__c = currentPage;
        }

        // Update status
        if (!String.isBlank(status)) {
            rl.Status__c = status;

            // Automatically set finish date if Finished
            if (status == 'Finished') {
                rl.Finish_Date__c = Date.today();
            } else {
                rl.Finish_Date__c = null;
            }
        }

        update rl;

        return rl;
    }
}
