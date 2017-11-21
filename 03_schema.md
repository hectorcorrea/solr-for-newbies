
To get a list of the fields in the schema

See also https://lucene.apache.org/solr/guide/7_1/schema-api.html#schema-api
```
$ curl localhost:8983/solr/bibdata/schema/fields

  #
  # Will return something like this
  # {
  #   ...
  #   {
  #     "name":"the name of the field",
  #     "type":"type of the field",
  #     "multiValued":true/false,
  #     "indexed":true/false,
  #     "stored":true/false
  #   },
  #   ...
  # }
  #
```

Let's add a new field
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"subjects",
     "type":"text_general",
     "multiValued":true,
     "stored":true,
     "indexed":true}
}' http://localhost:8983/solr/bibdata/schema

  #
  # {
  #  "responseHeader":{
  #  "status":0,
  #  "QTime":39}
  # }
  #
```
