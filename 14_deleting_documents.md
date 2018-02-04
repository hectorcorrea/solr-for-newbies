# Deleting all documents
To delete all documents for the `bibdata` core we can submit a request to Solr's
`update` endpoint (rather than the `select` endpoint) with a command like this:

```
$ curl "http://localhost:8983/solr/bibdata/update?commit=true" --data '<delete><query>*:*</query></delete>'
```

The body of the request (`--data`) indicates to Solr that we want to delete all documents (notice the `*:*` query).

You can also pass a more specific query, for example `id:00020424` to delete a single document or `title:teachers` to delete all documents where the title includes the word "teachers" (or a variation of it).

Be aware that even if you delete all documents from a Solr core the schema and the core's configuration will remain intact. For example, the fields that were defined are still available even if no documents exist in the core anymore.

If you want to delete the entire core (documents, schema, and other configuration associated with it) you can use the Solr delete command instead:

```
$ ~/solr-7.1.0/bin/solr delete -c bibdata
```

be aware that you will need to re-create the core if you want to re-import data to it.
