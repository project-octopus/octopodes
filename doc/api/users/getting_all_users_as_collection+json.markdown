# Users API

## Getting all users as Collection+JSON

### GET users
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>GET users</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 393
Date: Mon, 01 Dec 2014 12:23:35 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/users/","version":"1.0","items":[{"href":"http://example.org/users/user0","data":[{"name":"username","value":"user0","prompt":"Username"}]},{"href":"http://example.org/users/user1","data":[{"name":"username","value":"user1","prompt":"Username"}]}],"template":{"data":[{"name":"username","prompt":"Username"},{"name":"password","prompt":"Password"}]}}}</pre>
