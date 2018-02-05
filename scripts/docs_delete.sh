SOLR_URL="http://localhost:8983/solr/bibdata/update?commit=true"
SOLR_QUERY="<delete><query>*:*</query></delete>"
echo $SOLR_URL
echo $SOLR_QUERY
curl $SOLR_URL --data $SOLR_QUERY
