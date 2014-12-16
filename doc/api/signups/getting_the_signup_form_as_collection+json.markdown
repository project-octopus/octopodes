# Signups API

## Getting the signup form as Collection+JSON

### GET signups
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>GET signups</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 171
Date: Tue, 16 Dec 2014 10:54:48 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/signups/","version":"1.0","template":{"data":[{"name":"username","prompt":"Username"},{"name":"password","prompt":"Password"}]}}}</pre>
