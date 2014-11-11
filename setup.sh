clear
echo 'schema data for couchdb'

echo 'creating db...'
curl -vX DELETE http://localhost:5984/collection-data-works
curl -vX PUT http://localhost:5984/collection-data-works

echo 'adding design document'
curl -vX PUT http://localhost:5984/collection-data-works/_design/all -d @design-doc.json
