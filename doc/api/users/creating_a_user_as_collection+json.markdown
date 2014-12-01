# Users API

## Creating a user as Collection+JSON

### POST users
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Content-Type: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST users</pre>

#### Body

<pre>{"template":{"data":[{"name": "username", "value": "newuser"}, {"name": "password", "value": "new password"}]}}</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Location: http://example.org/users/32c4118539df961a61fdabd28f8919f2
Content-Length: 0
Date: Mon, 01 Dec 2014 12:23:36 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>201 Created</pre>

