# Adding a new field
xxx

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
    "name":"my_new_field",
    "type":"text_general",
    "multiValued":true,
    "stored":true,
    "indexed":false
  }
}' http://localhost:8983/solr/bibdata/schema
```

TODO: elaborate on this
