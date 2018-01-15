## Solr
Solr's main focus is searching. As such Solr provides many advanced search features not available in other products and is able to execute advanced searches on large datasets while maintaining fast response times. On its [home page](https://lucene.apache.org/solr/) Solr advertises itself as

    Solr is the popular, blazing-fast,
    open source enterprise search platform built on Apache Lucene.

But searching in Solr is different from searching in other products like SQL and NoSQL databases. In this section we are going to review the basics of searching in Solr.


## What is Apache Lucene?

The core functionality that we have in Solr is provided by a Java library called Lucene. Lucene is [the brains behind](https://lucene.apache.org/solr/guide/7_0/) the "indexing and search technology, as well as spellchecking, hit highlighting and advanced analysis/tokenization capabilities" that we have seen in this tutorial.

But Lucene is a Java Library than can only be use from other Java programs. Solr is a wrapper around Lucene that allows us to use the Lucene functionality from any programming language that can submit HTTP requests (which is pretty much any language.)

This explains why we had to install Java to use Solr: Solr is a Java program that uses Lucene. The advantage of Solr over Lucene is that we can communicate via HTTP to Solr *without having to use Java* as shown in the following diagram:

```
                                              -------------------
                                              | Java Runtime    |
[client application] ----> HTTP request ----> | Solr --> Lucene |
                                              -------------------
```

In this diagram the *client application* could be a program written in Ruby or Python. In fact, as we have seen throughout the tutorial, it can also be a system utility like cURL or a web browser. Anything that can submit HTTP requests can communicate with Solr.
