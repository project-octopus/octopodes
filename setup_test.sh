clear
echo 'schema data for couchdb'

echo 'creating db...'
curl -vX DELETE http://localhost:5984/collection-data-works-test
curl -vX PUT http://localhost:5984/collection-data-works-test

echo 'adding design document'
curl -vX PUT http://localhost:5984/collection-data-works-test/_design/all -d @db/design-doc.json

echo 'adding collection data'
curl -vX PUT http://localhost:5984/collection-data-works-test/webpage0 -d @db/webpage0.json
