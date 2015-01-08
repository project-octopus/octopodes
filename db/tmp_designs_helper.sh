clear
echo 'design document for project octopus v1'

echo ''
echo 'Count works'
echo '==========='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/works"

echo ''
echo 'Count webpages'
echo '=============='
curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/webpages"

echo ''
echo 'All Domains (ignoring media files)'
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

#echo ''
#echo 'All works'
#echo '========='
#curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/works?reduce=false&include_docs=true" | underscore print

#echo ''
#echo 'All webpages'
#echo '========='
#curl -sX GET "http://localhost:5984/project-octopus-v1/_design/all/_view/webpages?reduce=false&include_docs=true" | underscore print
