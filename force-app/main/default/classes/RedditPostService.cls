public class RedditPostService {
    @AuraEnabled(cacheable=true)
    public static List<Reddit_Post__c> getRedditPosts() {
        try {
            return [SELECT Title__c, Author__c, Thumbnail__c, Selftext__c 
                    FROM Reddit_Post__c 
                    ORDER BY CreatedAt__c DESC LIMIT 40];
        } catch (Exception e) {
            System.debug('Error retrieving Reddit posts: ' + e.getMessage());
            return new List<Reddit_Post__c>(); // Return an empty list in case of error
        }
    }
}