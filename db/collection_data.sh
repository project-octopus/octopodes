clear
echo 'schema data for couchdb'

echo 'creating db...'
curl -vX DELETE http://localhost:5984/collection-data-works
curl -vX PUT http://localhost:5984/collection-data-works

echo 'adding design document'
curl -vX PUT http://localhost:5984/collection-data-works/_design/all -d @design-doc.json

echo 'adding collection data'
curl -vX PUT http://localhost:5984/collection-data-works/webpage0 -d @webpage0.json
curl -vX PUT http://localhost:5984/collection-data-works/webpage1 -d @webpage1.json
curl -vX PUT http://localhost:5984/collection-data-works/webpage2 -d @webpage2.json
curl -vX PUT http://localhost:5984/collection-data-works/webpage3 -d @webpage3.json
curl -vX PUT http://localhost:5984/collection-data-works/webpage4 -d @webpage4.json

curl -vX PUT http://localhost:5984/collection-data-works/person1 -d @person1.json
curl -vX PUT http://localhost:5984/collection-data-works/person2 -d @person2.json
