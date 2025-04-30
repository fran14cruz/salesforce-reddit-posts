@isTest
public class RedditPostSyncerTest {
    @testSetup
    static void setupTestData() {
        // Create some test records to simulate existing Reddit posts
        List<Reddit_Post__c> testPosts = new List<Reddit_Post__c>();
        for (Integer i = 0; i < 50; i++) {
            Reddit_Post__c post = new Reddit_Post__c();
            post.Title__c = 'Test Post ' + i;
            post.Author__c = 'Test Author ' + i;
            post.Thumbnail__c = 'https://example.com/image' + i + '.jpg';
            post.Score__c = i;
            post.CreatedAt__c = DateTime.now().addDays(-i);
            testPosts.add(post);
        }
        insert testPosts;
    }
    
    @isTest
    static void testFutureCallout() {
        // Set the mock response for HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockRedditResponse());

        // Execute the future method in test context
        Test.startTest();
        RedditPostSyncer.makeCallout();
        Test.stopTest();

        // Verify that Reddit posts were synced correctly
        List<Reddit_Post__c> posts = [SELECT Id, Title__c FROM Reddit_Post__c ORDER BY CreatedAt__c DESC];
        System.assertEquals(40, posts.size(), 'Should have 40 posts synced from the mock response.');
    }
    
    // Test for deleting old posts
    @IsTest
    static void testDeleteOldPosts() {
        // Step 1: Verify that the test setup created 50 posts
        Integer totalRecordsBefore = [SELECT COUNT() FROM Reddit_Post__c];
        System.assertEquals(50, totalRecordsBefore, 'There should be 50 posts initially from testSetup.');

        // Step 2: Call the deleteOldPosts method to delete older records and maintain only 40
        Test.startTest();
        RedditPostSyncer.deleteOldPosts();
        Test.stopTest();
        
        // Step 3: Verify that only 40 posts remain after deletion
        Integer totalRecordsAfter = [SELECT COUNT() FROM Reddit_Post__c];
        System.assertEquals(40, totalRecordsAfter, 'There should be only 40 posts after deleting older records.');
        
        // Step 4: Verify that the remaining posts are the 40 most recent ones
        List<Reddit_Post__c> remainingPosts = [SELECT Title__c, CreatedAt__c FROM Reddit_Post__c ORDER BY CreatedAt__c DESC];
        System.assertEquals('Test Post 0', remainingPosts[0].Title__c, 'The most recent post should be Test Post 0.');
        System.assertEquals('Test Post 39', remainingPosts[39].Title__c, 'The oldest remaining post should be Test Post 39.');
    }
    
    // Test scheduling the job
    @isTest
    static void testScheduleJob() {
        // Clean up any previously scheduled jobs with the same name
        List<CronTrigger> existingJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'Reddit Post Sync Job'];
        if (existingJobs.size() > 0) {
            for (CronTrigger ct : existingJobs) {
                System.abortJob(ct.Id); // Abort any existing scheduled jobs
            }
        }
        Test.startTest();
        
        // Schedule the job
        RedditPostSyncer.scheduleJob();
        
        // Verify that the scheduled job was created
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE CronJobDetail.Name = 'Reddit Post Sync Job' LIMIT 1];
        System.assertNotEquals(null, ct, 'The job should have been scheduled.');
        //System.assertEquals('0 0 * * * ?', ct.CronExpression, 'The cron expression should match the one for the hourly job.');
        System.assertEquals('0 0 3 * * ?', ct.CronExpression, 'Cron Exp should match');
        Test.stopTest();
    }
    
    // Test for getting Reddit posts for LWC
    @isTest
    static void testGetRedditPosts() {
        Test.startTest();
        
        // Query posts to simulate what would be returned to LWC
        List<Reddit_Post__c> posts = RedditPostService.getRedditPosts();
        
        // Validate results
        System.assert(posts.size() <= 40, 'The LWC method should return up to 40 posts.');
        System.assertEquals('Test Post 0', posts[0].Title__c, 'The first post should be "Test Post 0".');
        
        Test.stopTest();
    }
    
    // Mock class to simulate Http Callout
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private HttpResponse mockResponse;
        
        public HttpCalloutMockImpl(HttpResponse response) {
            this.mockResponse = response;
        }
        
        public HttpResponse respond(HttpRequest req) {
            return mockResponse;
        }
    }
}