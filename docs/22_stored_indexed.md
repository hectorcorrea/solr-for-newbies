## Stored vs indexed fields

There are two properties on a Solr field that control whether its values are `stored`, `indexed`, or both. Fields that are *stored but not indexed* can be fetched once a document has been found, but you cannot search by those fields (i.e. you cannot reference them in the `q` parameter). Fields that are *indexed but not stored* are the reverse, you can search by them but you cannot fetch their values once a document has been found (i.e. you cannot reference them in the `fl` parameter). Technically is also possible to [add a field that is neither stored nor indexed](https://stackoverflow.com/a/22298265/446681) but that's beyond this tutorial.

For example, let's say that we add the following fields to our Solr core:

* f_stored: a field stored but not indexed
* f_indexed: a field indexed but not stored
* f_both: a field both indexed and stored

Create `f_stored` field:
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
    "name":"f_stored",
    "type":"text_general",
    "multiValued":false,
    "stored":true,
    "indexed":false
  }
}' http://localhost:8983/solr/bibdata/schema
```

Create `f_indexed` field:
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
    "name":"f_indexed",
    "type":"text_general",
    "multiValued":false,
    "stored":false,
    "indexed":true
  }
}' http://localhost:8983/solr/bibdata/schema
```

Create `f_both` field:
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
    "name":"f_both",
    "type":"text_general",
    "multiValued":false,
    "stored":true,
    "indexed":true
  }
}' http://localhost:8983/solr/bibdata/schema
```

And now let's add a document with data for these new fields:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '[{
  "id": "f_demo",
  "f_stored": "stored",
  "f_indexed": "indexed",
  "f_both": "both",
  "name": "test stored vs indexed fields"
}]' http://localhost:8983/solr/bibdata/update?commit=true
```

If we query for this document notice how `f_stored` and `f_both` will be fetched but *not* `f_indexed` (even though we list it in the `fl` parameter) because `f_indexed` is not stored.

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=id:f_demo&fl=id,f_indexed,f_stored,f_both'

  # "response":{"numFound":1,"start":0,"docs":[
  # {
  #   "id":"f_demo",
  #   "f_stored":"stored",
  #   "f_both":"both"}]
  # }}
```

Keep in mind that we can search by `f_indexed` because it is indexed:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=f_indexed:indexed'

  # will find the document, but again, the value of field f_indexed
  # will not be included in results.
```

Notice that even though we are able to fetch the value for the `f_stored` field we cannot use it for searches:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=f_stored:stored'

  # will return no results
  #   "response":{"numFound":0,"start":0,"docs":[]
```

Lastly, our indexed and stored field (`f_both`) can be searched for and fetched.


### Indexed, stored, and docValues

In the previous example we declared three fields with different indexed/stored settings and all of them were of type `text_general`. However, if you set the indexed/stored setting in fields of type `string` the default behavior is slightly different because Solr stores and handles `string` fields different from `text_general` fields.

For `string` fields, Solr adds an extra property [DocValues](https://lucene.apache.org/solr/guide/7_1/docvalues.html#docvalues) and sets it to true by default. This is an optimization that allows Solr to perform better when searching and faceting values in these fields but, as a result, fields with `docValue=true` behave as fields *indexed and stored* regardless of the value set for `stored` and `indexed` properties!

You can prevent Solr from using `docValues` in a `string` field by setting `docValues=false`. This would allow you to control whether a field is really stored and index like we did for `text_general` fields. Unless you have a good reason to change the default value for `docValues` I would suggest not changing it.

Solr does not allow you to set `docValues=true` for `text_general` fields.
