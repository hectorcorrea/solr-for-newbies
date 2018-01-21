# Index Replication

[Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/index-replication.html)

The Replication request handler on the *master* Solr defined in the `solrconfig.xml` for this source data (e.g. `~/solr-7.1.0/server/solr/bibdata/conf/solrconfig.xml`)

```
<requestHandler name="/replication" class="solr.ReplicationHandler">
  <lst name="master">
    <str name="replicateAfter">optimize</str>
    <str name="backupAfter">optimize</str>
    <str name="confFiles">schema.xml,stopwords.txt</str>
  </lst>
</requestHandler>
```

The Replication request handler on the *target* Solr defined in the `solrconfig.xml` where the data will be copied to (e.g. `~/solr-7.1.0/server/solr/other/conf/solrconfig.xml`)

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
