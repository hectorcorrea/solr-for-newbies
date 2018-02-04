# Adding a new field
So far we have only worked with the fields that were automatically added to our `bibdata` core as we imported the data. Let us now add and customize some of the fields in our core to have more control on how Solr indexes and searches data.


## Customizing the author fields
Our JSON file with the source data has a main author (the `author` property) and other authors (the `authorsOther` property). We know `author` is single value but `authorsOther` is multi-value. If we let Solr create these fields both of them will be multi-value so let's define them in our schema so that we can customize them.

Run the following command to create the `author` field as single value:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
      "name":"author",
      "type":"text_general",
      "multiValued":false
    }
}' http://localhost:8983/solr/bibdata/schema
```

Run the following command to create the `authorsOther` field as multi-value:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
      "name":"authorsOther",
      "type":"text_general",
      "multiValued":true
    }
}' http://localhost:8983/solr/bibdata/schema
```

Let's say that we want to create a single field in our Solr schema to store the combination of all the authors (`author` + `authorsOther`). We could define a new multi-value field as follow:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":[{
    "name":"authorsAll",
    "type":"text_general",
    "multiValued":true
  }]
}' http://localhost:8983/solr/bibdata/schema
```

Now let's configure Solr to automatically copy the values of `author` and `authorOther` to our new `authorAll` field by defining two `copy-fields`.

Run the following command to define a `copy-field` to copy the `author` to our new `authorsAll` field:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
    "source":"author",
    "dest":[ "authorsAll" ]
  }
}' http://localhost:8983/solr/bibdata/schema
```

Run the following command to define another `copy-field` to copy the `authorsOther` to our new `authorsAll` field:

```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-copy-field":{
    "source":"authorsOther",
    "dest":[ "authorsAll" ]
  }
}' http://localhost:8983/solr/bibdata/schema
```

Having a single `authorsAll` field will allow us to find books authored by a particular person regardless of whether they were the main author or not.

We need to re-import our data for these changes to take effect, but before we do this let's do another customization to the schema.


## Customizing the title fields
Most (if not all) the titles in our source JSON file are in English. Therefore let's configure the `title` field to use the `text_en` (text English) field type rather than the default `text_general` field type.

Field type `text_general` uses the standard tokenizer and two basic filters (StopFilter and LowerCase). In contrast `text_en` uses a similar configuration but it adds three more filters to the definition (EnglishPossessive, KeywordMarker, and PorterStem) that allow for more sophisticated queries. You can run `curl localhost:8983/solr/bibdata/schema/fieldtypes/text_general` and `curl localhost:8983/solr/bibdata/schema/fieldtypes/text_en` to validate this.


To define our `title` field run the following command:
```
$ curl -X POST -H 'Content-type:application/json' --data-binary '{
  "add-field":{
      "name":"title",
      "type":"text_en"
    }
}' http://localhost:8983/solr/bibdata/schema
```


## Testing our changes
Now that we have configured our schema with a few  specific field definitions let's re-import the data so that fields are indexed using the new configuration.

```
$ post -c bibdata data/books.json
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
