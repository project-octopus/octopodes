clear
echo 'design document for project octopus v1'

echo ''
echo 'Total works'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/works"

echo ''
echo 'Total published works'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/publications"

echo ''
echo 'Total edits'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/edits"

echo ''
echo 'Total users'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/users"

echo ''
echo 'All users'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/users?reduce=false"

echo ''
echo 'All Domains'
echo '=================================='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/domains?group_level=1"

echo ''
echo 'Everything on en.wikipedia.org'
echo '=============================='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/domains?reduce=false&startkey=%5B%22en.wikipedia.org%22%5D&endkey=%5B%22en.wikipedia.org%22%2C%20%7B%7D%5D"

echo ''
echo 'Everything on rijksmuseum.nl'
echo '============================'
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/domains?reduce=false&startkey=%5B%22rijksmuseum.nl%22%5D&endkey=%5B%22rijksmuseum.nl%22%2C%20%7B%7D%5D"

echo ''
echo 'Everything for The Threatened Swan'
echo '=================================='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/by_work?reduce=false&startkey=%5B%22works%2F1%22%5D&endkey=%5B%22works%2F1%22%2C%20%7B%7D%5D"

echo ''
echo 'All Edits for Work 1'
echo '===================='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/edits?reduce=false&endkey=%5B%22works%2F1%22%5D&startkey=%5B%22works%2F1%22%2C%20%7B%7D%5D&descending=true"

echo ''
echo 'All Edits by mzeinstra'
echo '===================='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/by_reviewer?reduce=false&startkey=%5B%22users%2Fmzeinstra%22%2C%20%7B%7D%5D&endkey=%5B%22users%2Fmzeinstra%22%5D&descending=true"
