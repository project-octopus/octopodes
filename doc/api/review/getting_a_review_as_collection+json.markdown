# Review API

## Getting a review as Collection+JSON

### GET /reviews/:id
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>GET /reviews/webpage0</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 535
Date: Mon, 01 Dec 2014 12:23:35 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/reviews/","version":"1.0","items":[{"href":"http://example.org/reviews/webpage0","data":[{"name":"name","value":"Stanley Wong","prompt":"Title"},{"name":"creator","value":"Christopher Adams","prompt":"Creator"},{"name":"license","value":"https://creativecommons.org/licenses/by/2.0/","prompt":"License"},{"name":"date","value":"2014-09-01T10:37:27+00:00","prompt":"Date"}],"links":[{"href":"https://www.flickr.com/photos/christopheradams/3174263710/","rel":"full","prompt":"Web Page URL"}]}]}}</pre>
