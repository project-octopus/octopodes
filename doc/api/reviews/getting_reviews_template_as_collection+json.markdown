# Reviews API

## Getting reviews template as Collection+JSON

### GET reviews;template
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Authorization: Basic dXNlcjE6cGFzczE=
Host: example.org
Cookie: </pre>

#### Route

<pre>GET reviews;template</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 477
Date: Tue, 16 Dec 2014 10:54:45 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/reviews/","version":"1.0","links":[{"href":"http://example.org/reviews;template","rel":"template","prompt":"Add a Work"}],"template":{"data":[{"name":"url","prompt":"Web Page URL"},{"name":"name","prompt":"Title"},{"name":"contentUrl","prompt":"Media File URL"},{"name":"creator","prompt":"Creator"},{"name":"license","prompt":"License"},{"name":"description","prompt":"Description"},{"name":"isBasedOnUrl","prompt":"Based on URL"}]}}}</pre>
