# PART II: SCHEMA

The schema in Solr is the definition of the *field types* and *fields* configured for a given core.

**Field Types** are the building blocks to define fields in our schema. Examples of field types are: `binary`, `boolean`, `pfloat`, `string`, and `text_general`. These are akin to the "field types" that are supported in a relational database like MySQL but, as we will see later, they are far more configurable than what you can do in a relational database.

There are three kind of fields that can be defined in a Solr schema:

* **Fields** are the specific fields that you define for your particular core. Fields are based of a "field type", for example, we might define field `title` based of the `string` field type and a field `price` base of the `pfloat` field type.

* **dynamicFields** are field patterns that we define to automatically create new fields when the data submitted to Solr matches the given pattern. For example, we can define that if receive data for a field that ends with `_txt` the field will be create it as a `text_general` field type.

* **copyFields** are instructions to tell Solr how to automatically copy the value given for one field to another field. This is useful if we want to do and store different transformation on the values given to us. For example, we might want to remove punctuation characters for searching but preserve them for display purposes.

Our newly created `bibdata` core already has a schema, you can view how the details of it via the [Schema API](https://lucene.apache.org/solr/guide/7_1/schema-api.html) as shown in the following example. The response will be rather long but it will be roughly include the following categories under the "schema" element:

```
$ curl localhost:8983/solr/bibdata/schema

  # {
  #   "responseHeader": {"status": 0, "QTime": 2},
  #   "schema": {
  #     "fieldTypes":   [lots of field types defined],
  #     "fields":       [lots of fields defined],
  #     "dynamicFields":[lots of dynamic fields defined],
  #     "copyFields":   [a few copy fields defined]
  #   }
  # }
  #
```

You can also view this information via the [Solr Admin](http://localhost:8983/solr/#/bibdata/schema) web page, under the *Schema* menu option or by looking at the `managed-schema` file under the *Files* menu option.

You can request each of these categories individually with the following commands (notice that combined words like `fieldTypes` and `dynamicFields` are *not* capitalized in the URLs below):

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes
$ curl localhost:8983/solr/bibdata/schema/fields
$ curl localhost:8983/solr/bibdata/schema/dynamicfields
$ curl localhost:8983/solr/bibdata/schema/copyfields
```

Notice that unlike a relational database, where only a handful field types are available to choose from (e.g. integer, date, boolean, char, and varchar) in Solr there are lots of predefined field types available out of the box, and each of them with its own configuration.

**Note for Solr 4.x users:** In Solr 4 the default mechanism to update the schema was by editing the file `schema.xml`. Starting in Solr 5 the default mechanism is through the "Managed Schema Definition" which uses the Schema API to add, edit, and remove fields. There is a `managed-schema` file with the same information as `schema.xml` but you are not supposed to edit this new file. See section "Managed Schema Definition in SolrConfig" in the [Solr Reference Guide 5.0 (PDF)](https://archive.apache.org/dist/lucene/solr/ref-guide/apache-solr-ref-guide-5.0.pdf) for more information about this.


## Fields in our schema

You might be wondering where did the fields like `id`, `title`, `author`, `subjects`, and `subjects_str` in our `bibdata` core come from since we never explicitly defined them.

Solr automatically created most of these fields when we imported the data from the `books.json` file. If you look at a few of the elements in the `books.json` file you'll recognize that they match some of the fields defined in our schema.

You can disable the automatic creation of fields in Solr if you don't want this behavior. Keep in mind that if automatic field creation is disabled Solr will *reject* the import of any documents with fields not defined in the schema. Note: I believe the ability to disable automatic field creation is new in Solr 6.x. Need to find out the exact version this became available.


### Field: id
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

Notice how the field is of type `string` but also it is marked as not multi-value, to be indexed, required, and stored.

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

In this case the `class` points to an internal Solr class that will be used to handle values of the string type.


### Field: title

Now let's look at a more complex field and field type. Let's look at the definition for the `title` type:

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

That looks innocent enough: our `title` field points to the type `text_general` so let's see what does `text_general` means:

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

This is obviously a much more complex definition than the ones we saw before. Although the basics are the same, the field type points to a `class` (solr.TextField) and it indicates it's a multi-value type, notice the next two properties defined for this field: `indexAnalyzer` and `queryAnalyzer`. We will explore those in the next section.
