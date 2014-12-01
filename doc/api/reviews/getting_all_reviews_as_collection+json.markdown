# Reviews API

## Getting all reviews as Collection+JSON

### GET reviews
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>GET reviews</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 753
Date: Mon, 01 Dec 2014 12:23:35 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/reviews/","version":"1.0","items":[{"href":"http://example.org/reviews/webpage0","data":[{"name":"name","value":"Stanley Wong","prompt":"Title"},{"name":"creator","value":"Christopher Adams","prompt":"Creator"},{"name":"license","value":"https://creativecommons.org/licenses/by/2.0/","prompt":"License"},{"name":"date","value":"2014-09-01T10:37:27+00:00","prompt":"Date"}],"links":[{"href":"https://www.flickr.com/photos/christopheradams/3174263710/","rel":"full","prompt":"Web Page URL"}]}],"template":{"data":[{"name":"url","prompt":"Web Page URL"},{"name":"name","prompt":"Title"},{"name":"creator","prompt":"Creator"},{"name":"license","prompt":"License"},{"name":"isBasedOnUrl","prompt":"Based on URL"}]}}}</pre>
