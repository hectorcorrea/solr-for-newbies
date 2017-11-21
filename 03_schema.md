# Schema

The schema in Solr is the definition of the *field types* and *fields* configured
for a given core.

**Field Types** are the building blocks to define fields in our schema. Examples
of field types are: `binary`, `boolean`, `pfloat`, `string`, and `text_general`.
These are akin to the "field types" that are supported in a relational database
like MySQL but, as we will see later, they are far more configurable than what you can do in a relational database.

There are three kind of fields that can be defined in a Solr schema:

* **Fields** are the specific fields that you define for your particular core.
Fields are based of a "field type", for example, we might define field `lastname`
based of the `string` field type and a field `price` base of the `pfloat` field type.

* **dynamicFields** are field patterns that we define to automatically create
new fields when the data submitted to Solr matches the given pattern. For example,
we can define that if receive data for a field that ends with `_txt` the field
will be create it as a `text_general` field type.

* **copyFields** are instructions to Solr to indicate that we want to automatically
copy the value given for one field to another field. This is useful if we want to
do and store different transformation on the values given to us. For example, we
might want to remove punctuation characters for searching but preserve them for
display purposes.

Our newly created `biddata` core already has a schema, you can view how the
details of this schema via the following command. The response will be rather
long but it will be roughly include the following categories under the "schema"
element:

```
$ curl localhost:8983/solr/bibdata/schema/fields

  # {
  #   "responseHeader": {"status": 0, "QTime": 2},
  #   "schema": {
  #     "fieldTypes":   [lots of types defined],
  #     "fields":       [lots of fields defined],
  #     "dynamicFields":[lots of dynamic fields defined],
  #     "copyFields":   [a few copy fields defined]
  #   }
  # }
  #
```

You can request each of these categories individually with the following commands
(notice that the words are not capitalized in the URLs):

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes
$ curl localhost:8983/solr/bibdata/schema/fields
$ curl localhost:8983/solr/bibdata/schema/dynamicfields
$ curl localhost:8983/solr/bibdata/schema/copyfields
```

**Note:** Unlike a relational database, where only a handful field types are
available to choose from (e.g. integer, date, boolean, char, and varchar) in Solr
there are lots of predefined field types available out of the box, and each of
them with its own configuration.


## Fields
Let's look at the details the `id` field in our schema

```
$ curl localhost:8983/solr/bibdata/schema/fields/id

  #
  # Will return something like this
  # {
  #   "responseHeader":{...},
  #   "field":{
  #    "name":"id",
  #    "type":"string",
  #    "multiValued":false,
  #    "indexed":true,
  #    "required":true,
  #    "stored":true
  #   }
  # }
  #
```

Notice how the field is of type `string` but also it is marked as not multi-value,
to be indexed, required, and stored.

The type `string` has also its own definition which we can view via:

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes/string

  # {
  #   "responseHeader":{...},
  #   "fieldType":{
  #     "name":"string",
  #     "class":"solr.StrField",
  #     "sortMissingLast":true,
  #     "docValues":true
  #   }
  # }
  #
```

In this case the `class` value points to an internal Solr class that will be used
to handle values of the string type.


Now let's look at a more complex field and field type. Let's look at the definition
for the `title` type:

```
$ curl localhost:8983/solr/bibdata/schema/fields/title

  # {
  #   "responseHeader":{...}
  #   "field":{
  #     "name":"title",
  #     "type":"text_general"
  #   }
  # }
  #
```

That looks innocent enough: our `title` field points to the type `text_general`
so let's see what does `text_general` means:

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes/text_general

  # {
  #   "responseHeader":{...}
  #   "fieldType":{
  #     "name":"text_general",
  #     "class":"solr.TextField",
  #     "positionIncrementGap":"100",
  #     "multiValued":true,
  #     "indexAnalyzer":{
  #       "tokenizer":{
  #         "class":"solr.StandardTokenizerFactory"
  #       },
  #       "filters":[
  #         {
  #           "class":"solr.StopFilterFactory",
  #           "words":"stopwords.txt",
  #           "ignoreCase":"true"
  #         },
  #         {
  #           "class":"solr.LowerCaseFilterFactory"
  #         }
  #       ]
  #     },
  #     "queryAnalyzer":{
  #       "tokenizer":{
  #         "class":"solr.StandardTokenizerFactory"
  #       },
  #       "filters":[
  #         {
  #           "class":"solr.StopFilterFactory",
  #           "words":"stopwords.txt",
  #           "ignoreCase":"true"
  #         },
  #         {
  #           "class":"solr.SynonymGraphFilterFactory",
  #           "expand":"true",
  #           "ignoreCase":"true",
  #           "synonyms":"synonyms.txt"
  #         },
  #         {
  #           "class":"solr.LowerCaseFilterFactory"
  #         }
  #       ]
  #     }
  #   }
  # }
```

This is obviously a much more complex definition than the ones that we saw
before. The basic are the same, the field type points to a `class` (solr.TextField)
and it also indicates that it is a multi-value type. However, notice the next two kinds
of information defined for this field, namely the information under the
`indexAnalyzer` and `queryAnalyzer`.

`indexAnalyzer` refers to the kind of transformations that will be made to
any field of this type before the value is indexed by Solr.

`queryAnalyzer` refers to the transformations that will be made to any
value that references a field of this type when we query a `text_general` field.

Notice for example how it will take into account "stop words" (e.g. words to be
ignored) both at index and query time, but it will take into account "synonyms"
only at querying time.


## Tokenizers and Filters  
Tokenizer splits words, for example if we index "hello world" a tokenizer
will split it in two "hello" and "word".

Filters to other operations on the value. For example, a "stemmer" gets the
roots of the word

In the definition of the `text_general` we see a tokenizer but not a stemmer.

If we look at the `text_en` field type instead we'll see that it uses both a
tokenizer and a stemmer (solr.PorterStemFilterFactory)

TODO: elaborate on this.


### Adding a new field

Let's add a new field
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
     "name":"callnumbers",
     "type":"strings",
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


## More information
The Solr Reference Guide https://lucene.apache.org/solr/guide/7_1/schema-api.html#schema-api
