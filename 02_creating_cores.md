# Creating our first Solr core
Solr uses the concept of *cores* to represent independent environments in which
we configure data schemas and store data. This is similar to the concept of a
"database" in MySQL or PostgreSQL.

For our purposes, let's create a core named `bibdata` via the following command:

```
$ cd ~/solr-7.1.0/bin
$ ./solr create -c bibdata

  #
  # WARNING: Using _default configset. Data driven schema functionality is enabled by default, which is
  #          NOT RECOMMENDED for production use.
  #
  #          To turn it off:
  #             curl http://localhost:8983/solr/bibdata/config -d '{"set-user-property": {"update.autoCreateFields":"false"}}'
  #
  # Created new core 'bibdata'
  #
```

Now we have a new core available to store documents. We'll ignore the warning because we are not in production, but we'll discuss this later on.

For now our core is empty (since we haven't added any thing to it) and you can check this with the following command from the terminal:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*:*'

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

you'll see `"numFound":0` indicating that there are no documents on it.
