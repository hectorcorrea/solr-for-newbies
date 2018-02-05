# Define the author fields that we need (author, authorsOther, authorsAll)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":[
    {
      "name":"author",
      "type":"text_general",
      "multiValued":false
    },
    {
      "name":"authorsOther",
      "type":"text_general",
      "multiValued":true
    },
    {
      "name":"authorsAll",
      "type":"text_general",
      "multiValued":true
    }
  ]
}' http://localhost:8983/solr/bibdata/schema


# Define a couple of copy fields (author to authorsAll, authorsOther to authorsAll)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":[
    {
      "source":"author",
      "dest":[ "authorsAll" ]
    },
    {
      "source":"authorsOther",
      "dest":[ "authorsAll" ]
    }
  ]
}' http://localhost:8983/solr/bibdata/schema



# Make sure the title field uses text_english field type.
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
      "name":"title",
      "type":"text_en"
    }
}' http://localhost:8983/solr/bibdata/schema


# Re-import our data
# post -c bibdata data/books.json


# Look at this particular record
# curl "http://localhost:8983/solr/bibdata/select?q=id:00000154"


# Test the title search
# curl 'http://localhost:8983/solr/bibdata/select?fl=title&q=title:run'
