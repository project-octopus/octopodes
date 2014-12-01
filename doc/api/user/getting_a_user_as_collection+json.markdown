# User API

## Getting a user as Collection+JSON

### GET /users/:username
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>GET /users/user1</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Content-Length: 184
Date: Mon, 01 Dec 2014 12:23:36 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>200 OK</pre>

#### Body

<pre>{"collection":{"href":"http://example.org/users/","version":"1.0","items":[{"href":"http://example.org/users/user1","data":[{"name":"username","value":"user1","prompt":"Username"}]}]}}</pre>
