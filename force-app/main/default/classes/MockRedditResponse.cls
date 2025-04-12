@isTest
global class MockRedditResponse implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        
        // Mock JSON response from Reddit API
        String jsonResponse = '{"data":{"children":[{"data":{"title":"First Post","author_fullname":"t2_example1","thumbnail":"https://b.thumbs.redditmedia.com/example1.jpg","selftext":"This is the first post."}},{"data":{"title":"Second Post","author_fullname":"t2_example2","thumbnail":"https://b.thumbs.redditmedia.com/example2.jpg","selftext":"This is the second post."}}]}}';

        
        res.setBody(jsonResponse);
        return res;
    }
}