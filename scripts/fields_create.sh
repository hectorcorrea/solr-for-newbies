# Add support for multi-value text in english dynamic fields
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-dynamic-field":{
     "name":"*_txts_en",
     "type":"text_en",
     "multiValued":true}
}' http://localhost:8983/solr/bibdata/schema

# Copy title to a string field (for sorting)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":[
    {
      "source":"title_txt_en",
      "dest":[ "title_s" ]
    }
  ]
}' http://localhost:8983/solr/bibdata/schema

# Create a combined "authorsAll" field (for searching)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":[
    {
      "source":"author_txt_en",
      "dest":[ "authorsAll_txts_en" ]
    },
    {
      "source":"authorsOther_txts_en",
      "dest":[ "authorsAll_txts_en" ]
    }
  ]
}' http://localhost:8983/solr/bibdata/schema


# Copy publisher to a string field (for sorting and faceting)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":[
    {
      "source":"publisher_txt_en",
      "dest": "publisher_s",
      "maxChars": "100"
    }
  ]
}' http://localhost:8983/solr/bibdata/schema

# Copy subject to a string field (for faceting)
curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":[
    {
      "source":"subjects_txts_en",
      "dest": "subjects_ss",
      "maxChars": "100"
    }
  ]
}' http://localhost:8983/solr/bibdata/schema