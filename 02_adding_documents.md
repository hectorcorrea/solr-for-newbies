## Adding documents to Solr

In the last section we ran a query against Solr that showed use that our
newly created code `bibdata` has no documents in it. Remember that our call to

```
$ curl "http://localhost:8983/solr/bibdata/select?q=*:*"
```

returned `"numFound":0`. Now let's add a few documents to our "bibdata" core.
First, download file:

```
$ curl "https://raw.githubusercontent.com/hectorcorrea/solr-for-newbies/master/data/books.json" > books.json

  #
  # You'll see something like this...
  # % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                Dload  Upload   Total   Spent    Left  Speed
  # 100  146M  100  146M    0     0  7081k      0  0:00:21  0:00:21 --:--:-- 8597k
  #
```

File `books.json` contains a small sample data a set with information about a
few books. Go ahead and take a look at it (e.g. via `cat books.json`)

Then, import this file our `bibdata` core with the `post` utility that Solr
provides out of the box:

```
$ ~/solr-7.1.0/bin/post -c bibdata data/exampledocs/books.json"

  #
  # (some text here...)
  # POSTing file books.json (application/json) to [base]/json/docs
  # 1 files indexed.
  # COMMITting Solr index changes to http://localhost:8983/solr/bibdata/update...
  # Time spent: 0:00:00.324
  #  
```

## Deleting all documents
To delete all documents for the `bibdata` core we can submit a request to Solr's
`update` endpoint (rather than the `select` endpoint) with a command like this:

```
$ curl "http://localhost:8983/solr/bibdata/update?commit=true" --data '<delete><query>*:*</query></delete>'
```

The body of the request (`--data` above) indicates to Solr that we want to delete
all documents (notice the `*:*` query).

Be aware that this will delete the documents but the schema and the core's configuration
will remain intact. For example, the fields that were defined are still available. You can
re-import documents to this core.

If you want to delete the entire core (documents, schema, and other configuration)
you can use the Solr delete command instead:

```
$ ~/solr-7.1.0/bin/solr delete -c bibdata
```

but notice that you will need to re-create the core after it if you want to
re-import data to it.
