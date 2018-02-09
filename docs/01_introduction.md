# PART I: INTRODUCTION

## What is Solr

Solr is an open source *search engine* developed by the Apache Software Foundation. On its [home page](https://lucene.apache.org/solr/) Solr advertises itself as

    Solr is the popular, blazing-fast,
    open source enterprise search platform built on Apache Lucene.

and the book [Solr in Action](https://www.worldcat.org/title/solr-in-action/oclc/879605085) describes Solr as

    Solr is a scalable, ready-to-deploy enterprise search engine
    that’s optimized to search large volumes of text-centric data
    and return results sorted by relevance [p. 4]

The fact that Solr is a search engine means that there is a strong focus on speed, large volumes of text data, and the ability to sort the results by relevance.

Although Solr could technically be described as a NoSQL database (i.e. it allows us to store and retrieve data in a non-relational form) it is better to think of it as a search engine to emphasize the fact that it is better suited for text-centric and read-mostly environments [Solr in Action, p. 4].


### Solr's document model

Solr uses a document model to represent data. Documents are [Solr's basic unit of information](https://lucene.apache.org/solr/guide/7_0/overview-of-documents-fields-and-schema-design.html#how-solr-sees-the-world) and they can contain different fields depending on what information they represent. For example a book in a library catalog stored as a document in Solr might contain fields for author, title, and subjects, whereas information about a house in a real estate system using Solr might include fields for address, taxes, price, and number of rooms.

Something important to know about documents in Solr is that they are self-contained and don't contain nested fields:

    a document in a search engine like Solr has a flat structure and doesn’t
    depend on other documents. The flat concept is slightly relaxed in Solr,
    in that a field can have multiple values, but fields don’t contain
    subfields. You can store multiple values in a single field, but you
    can’t nest fields inside of other fields. [Solr in Action, p. 6]

This is different from other document stores, like MongoDB, that allow nested fields inside a document.


### Inverted index

Search engines like Solr use a data structure called *inverted index* to support fast retrieval of documents even with complex query expression on large datasets. The basic idea of an inverted index is to use the *terms* inside a document as the *key* of the index rather than the *document's ID* as the key.

Let's illustrate this with an example. Suppose we have three books that we want to index. With a traditional index we would create something like this:

```
ID      TITLE
--      ----------------
1       DC guide for dogs
2       DC tour guide
3       cats and dogs
```

With an inverted index we would take each of the words in the title of our books and use those words as the index key:

```
KEY     DOCUMENT ID
----    -----------------
DC      1, 2
guide   1, 2
dogs    1, 3
tour    2
cats    3
```

Notice that the inverted index allow us to do searches for individual *words within the title*. For example a search for the word "guide" immediately tell us that documents 1 and 2 are a match. Likewise a search for "tour" will tells that document 2 is a match.

Chapter 3 in Solr in Action has a more comprehensive explanation of how Solr uses inverted indexes to allow for partial matches as well as to aid with the ranking of the results.


### What is Lucene

The core functionality that Solr makes available is provided by a Java library called Lucene. Lucene is [the brains behind](https://lucene.apache.org/solr/guide/7_0/) the "indexing and search technology, as well as spellchecking, hit highlighting and advanced analysis/tokenization capabilities" that we will see in this tutorial.

But Lucene is a Java Library than can only be used from other Java programs. Solr on the other hand is a wrapper around Lucene that allows us to use the Lucene functionality from any programming language that can submit HTTP requests.

```
                                              -------------------
                                              | Java Runtime    |
[client application] ----> HTTP request ----> | Solr --> Lucene |
                                              -------------------
```

In this diagram the *client application* could be a program written in Ruby or Python. In fact, as we will see throughout this tutorial, it can also be a system utility like cURL or a web browser. Anything that can submit HTTP requests can communicate with Solr.
