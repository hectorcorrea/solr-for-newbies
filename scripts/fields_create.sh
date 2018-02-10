# Adds a few custom fields to the bibdata core
# (author, authorsOther, authorsAll, title, title_)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":[
    {
      "name":"author",
      "type":"string",
      "multiValued":false
    },
    {
      "name":"authorsOther",
      "type":"string",
      "multiValued":true
    },
    {
      "name":"authorsAll",
      "type":"text_general",
      "multiValued":true
    }
  ]
}' http://localhost:8983/solr/bibdata/schema

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

curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
    "name":"title",
    "type":"text_en",
    "multiValued":false
  },
  "add-copy-field":{
    "source":"title",
    "dest":[ "title_s" ]
  }
}' http://localhost:8983/solr/bibdata/schema
