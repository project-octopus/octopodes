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
Content-Length: 1334
Date: Tue, 16 Dec 2014 10:54:45 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/reviews/","version":"1.0","links":[{"href":"http://example.org/reviews;template","rel":"template","prompt":"Add a Work"}],"items":[{"href":"http://example.org/reviews/baddata_webpage","data":[{"name":"name","value":"The Work","prompt":"Title"},{"name":"creator","value":"The Creator","prompt":"Creator"},{"name":"reviewedBy","value":"user0","prompt":"Reviewed By"},{"name":"date","value":"2014-12-01T10:37:27+00:00","prompt":"Date"},{"name":"url","value":"http://www.europeana.eu/portal/recordhttp://mint-projects /KIK-IRPA, Brussels","prompt":"Web Page"},{"name":"isBasedOnUrl","value":"http://mint-projects /KIK-IRPA, Brussels","prompt":"Original"}]},{"href":"http://example.org/reviews/webpage0","data":[{"name":"name","value":"Stanley Wong","prompt":"Title"},{"name":"creator","value":"Christopher Adams","prompt":"Creator"},{"name":"license","value":"https://creativecommons.org/licenses/by/2.0/","prompt":"License"},{"name":"reviewedBy","value":"user1","prompt":"Reviewed By"},{"name":"date","value":"2014-09-01T10:37:27+00:00","prompt":"Date"}],"links":[{"href":"https://www.flickr.com/photos/christopheradams/3174263710/","rel":"full","prompt":"Web Page URL"},{"href":"https://farm4.staticflickr.com/3087/3174263710_5a4e3bee62_b.jpg","rel":"contentUrl","prompt":"Media File URL"}]}]}}</pre>
