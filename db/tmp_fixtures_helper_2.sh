clear
echo 'test data for project octopus v1'

echo 'creating db...'
curl -sX DELETE http://localhost:5984/project-octopus-v1
curl -sX PUT http://localhost:5984/project-octopus-v1

echo 'adding collection data'
curl -sX POST -H "Content-Type: application/json" http://localhost:5984/project-octopus-v1/_bulk_docs --data-binary @fixtures/v1-3.json

echo 'adding design document'
curl -sX PUT -H "Content-Type: application/json" http://localhost:5984/project-octopus-v1/_design/all --data-binary @designs/v1-3.json
