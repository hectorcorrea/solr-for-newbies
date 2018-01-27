# Solr Replication

Replication is a technique in which you "create multiple identical copies of your index and load balance traffic across each of the copies" [Solr in Action, p. 375](https://www.worldcat.org/title/solr-in-action/oclc/879605085).

Solr supports replication out of the box and this is helpful to increase fault tolerance in systems. The basic idea is that if a server becomes unavailable a different server, with an exact copy of the data, can be used to handle search requests. You can also distribute the load between multiple servers at all times.

Solr uses the *one-master, many-replica* model to handle replication in which there is a single *master* server where documents are indexed and multiple *replica* servers where searches can be executed. The replica servers pull data from the master server on a regular basis.

    Fundamentally, replication requires a server to perform indexing (the master server),
    and a server to pull a copy of the index from the master (the [replica] server).
    - Solr in Action, p. 376

To configure replication in Solr we need to add a new request handler in our `solrconfig.xml` and by convention this handler is named `/replication`.


## Master server configuration

To define the server that will act as the *master* in our replication we will add the following handler to `~/solr-7.1.0/server/solr/bibdata/conf/solrconfig.xml`:

```
<requestHandler name="/replication" class="solr.ReplicationHandler">
  <lst name="master">
    <str name="replicateAfter">optimize</str>
    <str name="backupAfter">optimize</str>
    <str name="confFiles">schema.xml,stopwords.txt</str>
  </lst>
</requestHandler>
```

Notice the settings under the `master` section. These setting designate this server as the master server in the replication, indicate when the replication will take place, and what configuration files will be replicated. For more details on what each of the settings mean take a look at the [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/index-replication.html)

If you reload this core

```
$ curl 'http://localhost:8983/solr/admin/cores?action=RELOAD&core=theothercore'
```

and look at its setting under the [Replication](http://localhost:8983/solr/#/bibdata/replication) tab in the Solr Admin web page you should see a green checkbox next to the "replication enable" setting.


## Replica server configuration

For replication to work we need to have other Solr core (or cores) where the data will be replicated to. In a production setting these replica copies will typically live in a different machine from the master, but to keep things simple on this tutorial we are going to define the replica on the same machine and Solr installation that we have been using.

Let's start by defining a new core:

```
$ solr create -c theothercore
```

If you query `theothercore` it will have no documents since it is brand new.

```
# curl http://localhost:8983/solr/theothercore/select?q=*

  #
  # {
  #  "responseHeader":{
  #    "status":0,
  #    "QTime":3,
  #    "params":{
  #      "q":"*"}},
  #  "response":{"numFound":0,"start":0,"docs":[]
  #  }}
  #
```

Let's configure `theothercore` to be the replica our `bibdata` core. We do this by adding a `/replication` handler to the `solrconfig.xml` of our new core, in other words to the file at `~/solr-7.1.0/server/solr/theothercore/conf/solrconfig.xml`. The replication handler in this case will be marked as "slave" (rather than "master") as show below:

```
<requestHandler name="/replication" class="solr.ReplicationHandler">
  <lst name="slave">
    <str name="masterUrl">http://localhost:8983/solr/bibdata/replication</str>
    <str name="pollInterval">00:00:20</str>
    <str name="compression">internal</str>
    <str name="httpConnTimeout">5000</str>
    <str name="httpReadTimeout">10000</str>
    <str name="httpBasicAuthUser">username</str>
    <str name="httpBasicAuthPassword">password</str>
  </lst>
</requestHandler>
```

Notice that in these settings we indicate the URL of the master Solr index, in our case `http://localhost:8983/solr/bibdata/replication`. This is how the replica knows where to get the data from. We also indicated that we want the replicate to poll the master server every 20 seconds (`00:00:20`) for changes in the data (we will use a different interval if we were in production.)

Let's reload reload this core for the changes to take effect:

```
$ curl 'http://localhost:8983/solr/admin/cores?action=RELOAD&core=theothercore'
```

If we query the replica again we would see documents on it. Also, if we look at the settings under the [Replication](http://localhost:8983/solr/#/theothercore/replication) tab in the Solr Admin web page *for this new core* we would see information about the replication including the master URL and the polling interval.


## Sharding

Sharding is a different technique from replication that is used to execute *distributed queries* across multiple Solr cores. This is useful when you have too many documents to handle on a single server.

Sharding is beyond the scope of this tutorial but Chapter 12 of [Solr in Action](https://www.worldcat.org/title/solr-in-action/oclc/879605085) or the [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/legacy-scaling-and-distribution.html) are good places to start if you want to learn more about it.

Trivia: "One of the upper limits in Solr is that an index cannot contain more than 2^31 documents, due to an underlying limitation in Lucene." (Solr in Action, p. 372). That's two billion documents (2,000,000,000) for those of us that use the [short scale](https://en.wikipedia.org/wiki/Long_and_short_scales).


## SolrCloud

Solr also provides a feature known as SolrCloud that is now the preferred way to handle fault tolerance and high availability in large scale environments. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/solrcloud.html) defines it as:

    SolrCloud is flexible distributed search and indexing, without a master node
    to allocate nodes, shards and replicas. Instead, Solr uses ZooKeeper to manage
    these locations, depending on configuration files and schemas. Queries and
    updates can be sent to any server. Solr will use the information in the
    ZooKeeper database to figure out which servers need to handle the request.

This is also out of the scope of this tutorial.
