public with sharing class MemberReviewService {

    // ==================================================
    // 1️⃣ SUBMIT A REVIEW
    // ==================================================
    @AuraEnabled
    public static Id submitReview(
        Id bookId,
        Integer rating,
        String reviewTitle,
        String reviewBody
    ) {

        // Validate inputs
        if (bookId == null) {
            throw new AuraHandledException('Book is required');
        }

        if (rating == null || rating < 1 || rating > 5) {
            throw new AuraHandledException('Rating must be between 1 and 5');
        }

        // Get current user's Contact
        Contact member = [
            SELECT Id
            FROM Contact
            WHERE Email = :UserInfo.getUserEmail()
            LIMIT 1
        ];

        // Prevent duplicate review per book per member
        List<Member_Review__c> existing = [
            SELECT Id
            FROM Member_Review__c
            WHERE Book__c = :bookId
              AND Member__c = :member.Id
            LIMIT 1
        ];

        if (!existing.isEmpty()) {
            throw new AuraHandledException('You have already reviewed this book');
        }

        // Create review
        Member_Review__c review = new Member_Review__c(
            Book__c = bookId,
            Member__c = member.Id,
            Rating__c = rating,
            Review_Title__c = reviewTitle,
            Review_Body__c = reviewBody,
            Helpful_Count__c = 0,
            Is_Approved__c = true // ready for moderation
        );

        insert review;

        // Return the Review Id for UI reference
        return review.Id;
    }

    // ==================================================
    // 2️⃣ FETCH PUBLIC REVIEWS FOR A BOOK
    // ==================================================
    @AuraEnabled(cacheable=true)
    public static List<Member_Review__c> getReviews(Id bookId) {

        if (bookId == null) {
            return new List<Member_Review__c>();
        }

        return [
            SELECT Id,
                   Rating__c,
                   Review_Title__c,
                   Review_Body__c,
                   Helpful_Count__c,
                   Member__r.Name,
                   CreatedDate
            FROM Member_Review__c
            WHERE Book__c = :bookId
              AND Is_Approved__c = true
            ORDER BY CreatedDate DESC
        ];
    }

    // ==================================================
    // 3️⃣ HELPFUL UPVOTE
    // ==================================================
    @AuraEnabled
    public static void upvoteReview(Id reviewId) {

        if (reviewId == null) {
            throw new AuraHandledException('Review Id is required');
        }

        Member_Review__c review = [
            SELECT Id, Helpful_Count__c
            FROM Member_Review__c
            WHERE Id = :reviewId
            LIMIT 1
        ];

        Integer currentCount =
            review.Helpful_Count__c == null ? 0 : Integer.valueOf(review.Helpful_Count__c);

        review.Helpful_Count__c = currentCount + 1;

        update review;
    }
}
