# title_str field

Of the fields in the schema there are a few of them that look like the values in our JSON file but are *not* identical, for example there is a field named `title` and another `title_str` but we only have `title` in the JSON file. Where does `title_str` come from?

When we imported our data, because our `bibdata` core allows for automatic field creation, Solr guessed a type for the `title` field based on the data that we imported and assigned it `text_general` but *it also created a separate field* (`title_str`) to store a `string` version of the title values. This other field was created as a **copyField**. We can view its definition via the following command:

```
$ curl localhost:8983/solr/bibdata/schema/copyfields?dest.fl=title_str

  # response will include
  #
  # {
  #   "source":"title",
  #   "dest":"title_str",
  #   "maxChars":256
  # },
  #
```

This definition indicates that first 256 characters of the `title` will be copied to `title_str` field but it does not really tell us what kind of field `title_str` will be.

However, the `_str` suffix in the name is a common pattern used in Solr to identify **dynamicFields**. Dynamic Fields are used to tell Solr that any field name imported that matches a particular pattern (e.g. `*_str`) will be created with a particular field definition. Let's look at the default definition for the `*_str` pattern:

```
$ curl "localhost:8983/solr/bibdata/schema/dynamicfields/*_str"

  # response will include
  #
  # "dynamicField":{
  #   "name":"*_str",
  #   "type":"strings",
  #   "docValues":true,
  #   "indexed":false,
  #   "stored":false
  # }
  #
```

Notice how the `*_str` dynamic field definition will create a `strings` field for any field that ends with `_str`. You can see the definition of the `strings` field type via `curl localhost:8983/solr/bibdata/schema/fieldtypes/strings`

With all this information we can conclude that the first 256 characters of the `title` will be copied to a `title_str` field (via a **copyField**). The `title_str` will be created of the `*_txt` **dynamicField** definition as a `strings` type. `strings` in turn is a multi-value `string` field type.
