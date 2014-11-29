# Reviews API

## Posting a review as Collection+JSON

### POST reviews
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Content-Type: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST reviews</pre>

#### Body

<pre>{"template":{"data":[{"name": "name", "value": "Title"}, {"name": "url", "value": "http://example.org/web"}]}}</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Location: http://example.org/reviews/32c4118539df961a61fdabd28f6157d9
Content-Length: 0
Date: Fri, 28 Nov 2014 11:09:59 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>201 Created</pre>

