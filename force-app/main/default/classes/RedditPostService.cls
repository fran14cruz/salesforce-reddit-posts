public with sharing class RedditPostService {
    @AuraEnabled(cacheable=true)
    public static List<Reddit_Post__c> getRedditPosts() {
        try {
            return [SELECT
                        Title__c, 
                        Author__c,
                        Thumbnail__c,
                        Score__c,
                        CreatedDate
                    FROM Reddit_Post__c
                    WITH SECURITY_ENFORCED
                    ORDER BY CreatedAt__c
                    DESC LIMIT 40];
        } catch (Exception e) {
            System.debug('Error retrieving Reddit posts: ' + e.getMessage());
            return new List<Reddit_Post__c>(); // Return an empty list in case of error
        }
    }
}