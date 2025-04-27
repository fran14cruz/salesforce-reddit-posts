/* Author: Francisco Cruz
 * Created:
 * Last Modified: 
 * Description: This class retrives...
 * Version 1.0
 */
public with sharing class RedditPostSyncer implements Schedulable {

    public void execute(SchedulableContext sc) {
        // Call the future method to perform the callout
        RedditPostSyncer.makeCallout();
    }

    @future(callout=true)
    public static void makeCallout() {
        try {
            // Reddit API URL
            String apiUrl = 'https://www.reddit.com/r/aww.json';

            // Prepare HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl);
            req.setMethod('GET');

            Http http = new Http();
            HttpResponse res = http.send(req);

            // Handle the response
            if (res.getStatusCode() == 200) {
                // Parse the response
                Map<String, Object> jsonResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                List<Object> posts = (List<Object>)((Map<String, Object>)jsonResponse.get('data')).get('children');

                List<Reddit_Post__c> newPosts = new List<Reddit_Post__c>();

                for (Object postObj : posts) {
                    Map<String, Object> post = (Map<String, Object>)((Map<String, Object>)postObj).get('data');

                    // Create a new post record
                    Reddit_Post__c rp = new Reddit_Post__c();
                    String title = (String)post.get('title');
                    rp.Title__c = title.abbreviate(225);
                    rp.Author__c = (String)post.get('author_fullname');
                    rp.Thumbnail__c = (String)post.get('thumbnail');
                    rp.Selftext__c = (String)post.get('score');
                    rp.CreatedAt__c = DateTime.now(); // Store current date/time

                    newPosts.add(rp);
                }

                // Insert new posts and delete older ones
                if (!newPosts.isEmpty()) {
                    insert newPosts;
                    deleteOldPosts();  // Maintain the 40-post limit
                }
            } else {
                // Handle non-200 responses
                System.debug('Error: Received status code ' + res.getStatusCode() + ' from Reddit API');
            }
        } catch (Exception e) {
            // Error handling for failed HTTP requests
            System.debug('Error occurred during HTTP callout: ' + e.getMessage());
        }
    }

    // Delete posts older than the 40 most recent ones
    public static void deleteOldPosts() {
        try {
            List<Reddit_Post__c> olderPosts = [
                SELECT Id
                FROM Reddit_Post__c
                WITH SECURITY_ENFORCED
                ORDER BY CreatedAt__c DESC
                OFFSET 40
            ];
            if (!olderPosts.isEmpty()) {
                delete olderPosts;
            }
        } catch (Exception e) {
            // Error handling for deletion
            System.debug('Error occurred while deleting old posts: ' + e.getMessage());
        }
    }

    // Schedule this job
    public static void scheduleJob() {
        // CRON expression for every hour
        // String cronExp = '0 0 * * * ?';
        // CRON expression to run daily at 3am
        String cronExp = '0 0 3 * * ?';
        System.schedule('Reddit Post Sync Job', cronExp, new RedditPostSyncer());
    }
}