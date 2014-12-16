# Signups API

## Registering a user as Collection+JSON

### POST signups
### Request

#### Headers

<pre>Accept: application/vnd.collection+json
Content-Type: application/vnd.collection+json
Host: example.org
Cookie: </pre>

#### Route

<pre>POST signups</pre>

#### Body

<pre>{"template":{"data":[{"name": "username", "value": "newuser"}, {"name": "password", "value": "new password"}]}}</pre>

### Response

#### Headers

<pre>Content-Type: application/vnd.collection+json
Vary: Accept
Location: http://example.org/signups/bb45944fd45cb16ff860218e574c1e8c
Content-Length: 0
Date: Tue, 16 Dec 2014 10:54:48 GMT
Server: Webmachine-Ruby/1.2.2 Rack/1.2</pre>

#### Status

<pre>201 Created</pre>

