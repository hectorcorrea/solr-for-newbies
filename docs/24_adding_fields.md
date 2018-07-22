## Adding a new field
So far we have only worked with the fields that were automatically added to our `bibdata` core as we imported the data. Let us now add and customize some of the fields in our core to have more control on how Solr indexes and searches data.


### Customizing the author fields
Our JSON file with the source data has a main author (the `author` property) and other authors (the `authorsOther` property). We know `author` is single value and `authorsOther` is multi-value. When we let Solr automatically create these fields both of them ended up being multi-value so let's define them manually in our schema so that we can customize author to be single value so that we can sort our results by it (you can only sort by single-value fields).

Let's also create a new field (`authorsAll`) that will combine the main author with the other authors, that way we only need to search against a single field when searching by author. Notice that we are making this field `text_general` (rather than string) so that we can do partial matching.

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
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

  #
  # response will look like
  # {
  #   "responseHeader":{
  #     "status":0,
  #     "QTime":10}}
  #
```

Now let's configure Solr to automatically copy the values of `author` and `authorOther` to our new `authorAll` field by defining two `copy-fields`:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
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
```

We can see how these changes are now part of the schema by looking at the definitions of the `author`, `authorsOther`, and `authorsAll` in the [Solr Admin](http://localhost:8983/solr/#/bibdata/schema) tool either via the *Schema* menu option or by looking at the `managed-schema` file under the *Files* option.

We need to re-import our data for these changes to be applied to the data, but before we do this let's do another customization to the schema.


### Customizing the title fields
Most (if not all) the titles in our source JSON file are in English. Therefore let's configure the `title` field to be single-value and to use the `text_en` (text English) field type rather than the default multi-value `text_general` field type.

Field type `text_general` uses the standard tokenizer and two basic filters (StopFilter and LowerCase). In contrast `text_en` uses a similar configuration but it adds three more filters to the definition (EnglishPossessive, KeywordMarker, and PorterStem) that allow for more sophisticated queries. We can run `curl localhost:8983/solr/bibdata/schema/fieldtypes/text_general` and `curl localhost:8983/solr/bibdata/schema/fieldtypes/text_en` to see the specifics for these field types.

When we let Solr automatically create the `title` field based on the data that we imported, Solr also created a second field (`title_str`) with the string representation of the title. Now that we are explicitly defining the `title` field Solr won't automatically create the second field for us, but we can easily ask Solr to do it. We'll use the `_s` instead of `_str` because our new title field is single value.

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
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
```


### Testing our changes
Now that we have configured our schema with a few specific field definitions let's re-import the data so that fields are indexed using the new configuration.

```
$ cd ~/solr-7.4.0/bin
$ post -c bibdata books.json
```


### Testing changes to the author field

Take a look at the data for this particular book that has many authors and notice how the `authorsAll` field has the combination of `author` and `authorOthers` (even though our source data didn't have an `authorsAll` field.)

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=id:00000154'

  #
  # notice that authorsAll combines the data from author and authorsOther
  #
  # {
  #   "id":"00000154",
  #   ...
  #   "author":"Kropotkin, Petr Alekseevich,",
  #   ...
  #   "authorsOther":["Brandes, Georg,",
  #     "Agassiz, George R."],
  #   ...
  #   "authorsAll":["Kropotkin, Petr Alekseevich,",
  #      "Brandes, Georg,",
  #      "Agassiz, George R."],
  #   ...
  # }
  #
```

Likewise, let's search for books authored by "George" on the subject of "Throat" using our new `authorsAll` field (`q=authorsAll:george AND subjects:Throat`):

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,author,authorsAll,subjects&q=authorsAll:george+AND+subjects:Throat'

  #
  # response will include
  # {
  #   "id":"00006747",
  #   "author":"Ballenger, William Lincoln,",
  #   "authorsAll":["Ballenger, William Lincoln,",
  #     "Wippern, Adolphus George,"],
  #   "subjects":["Eye", "Ear", "Nose", "Throat"]
  # }
  #
```

notice that the result includes a book where "George" is one of the authors (even if he is not the main author.)

Another benefit of our customized `author` field is that, because we made it *string* and *single value*, we now can sort the results by author, for example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&sort=author+asc&fl=id,author'

  #
  # results will be sorted by author
  #
```

### Testing changes to the title field

Now run a query for books with the title "run" (`q=title:run`):

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=title&q=title:run'

  #
  # response will include
  #   ...
  #   {"title":"Marco's run /"},
  #   {"title":"50 trail runs in Southern California /"},
  #   {"title":"River running : canoeing, kayaking, rowing, rafting /"}
  #   ...
  #
```

notice that results include books with the title "run", "runs", and "running". This is thanks to the PorterStem filter that the `text_en` field type is using.

Similarly, run a query for books with title `its a dogs new york`:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=title&q=title:"its+a+dogs+new+york"'

  #
  # response will include
  #   ...
  #   {"title":"It's a dog's New York /"}
  #   ...
  #
```

notice that the results include a book titled "It's a dog's New York". This book was considered a match for our search because the `text_en` field type uses the EnglishPossessive filter that drop the trailing `'s` from the search terms which allowed Solr to find a match despite the poor spelling used in our search terms.


Important: Sorting a `string` field in Solr works as you would expect it, however sorting a `text_en` or `text_general` field field **does not** work because the value has been tokenized. As an exercise try sorting results by `title` (a `text_en` field) and by `title_s` (a `string` field) and compare the results:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=*&sort=title+asc'


$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=*&sort=title_s+asc'

```
