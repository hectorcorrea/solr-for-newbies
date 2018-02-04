## == Recreating our Solr core

Before we start the next section, where we will make customizations to the schema, let's delete the current core and re-create it empty.

To delete the `bibdata` core issue:

```
$ solr delete -c bibdata

  #
  # Deleting core 'bibdata' using command:
  # http://localhost:8983/solr/admin/cores?action=UNLOAD&core=bibdata...
  #
```

To re-create the core issue:

```
$ solr create -c bibdata

  #
  # Created new core 'bibdata'
  #
```

Making sure the core was created:

```
$ curl "http://localhost:8983/solr/bibdata/select?q=*:*"

  #
  # {
  #  "responseHeader":{
  #    "status":0,
  #    "QTime":0,
  #    "params":{
  #      "q":"*:*"}},
  #  "response":{"numFound":0,"start":0,"docs":[]
  #  }}
  #
```
