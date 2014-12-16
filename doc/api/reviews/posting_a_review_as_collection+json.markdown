# Reviews API

## Posting a review as Collection+JSON

### POST reviews
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Content-Type: application/vnd.collection+json
Authorization: Basic dXNlcjE6cGFzczE=
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
Location: http://example.org/reviews/bb45944fd45cb16ff860218e574b8b73
Content-Length: 0
Date: Tue, 16 Dec 2014 10:54:47 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>201 Created</pre>

