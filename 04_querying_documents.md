# Querying for documents

Now that we have added a few documents to our `bibdata` core we can query Solr
for those documents. In a subsequent section we'll explore more advanced
searching options and how our schema definition is key to enable different
kind of searches, but for now we'll start with a few basic searches to get
familiar with the way querying works in Solr.

If you look at the content of the `books.json` file that we imported into
our `bibdata` core you'll notice that the documents have the following fields:

* id: string to identify each document (MARC 001)
* author: string for the main author (MARC 100a)
* authorDate: date for the author (MARC 100d)
* authorFuller: title of the book (MARC 100q)
* title: title of the book (MARC 245ab)
* responsibility: statement of responsibility (MARC 245c)
* publisher: publisher name (MARC 260a)
* subjects: an array of subjects (MARC 650a)

## Fetching some fields
If we want to retrieve the `title` and `id` of each of these items we could issue a query like this:

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title&q=*:*"

  # The response will look something like this
  #
  # {
  #   "responseHeader":{
  #     "status":0,
  #     "QTime":0,
  #     "params":{
  #       "q":"*:*",
  #       "fl":"id,title"}},
  #   "response":{"numFound":10000,"start":0,"docs":[
  #       {
  #         "id":"00000009",
  #         "title":["Their silver wedding journey /"]},
  #       {
  #         ... 9 more results }
  #   ]}
  # }
  #
```

Notice the field list parameter `fl` in the previous command. This is a comma delimited list of fields that we want to fetch. Try adding and removing some other fields to this list, for example, `author` or `subjects`


## Filtering the documents

Now let's run a query like this to fetch all documents where the `title` includes the word "teachers":

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teachers"

  # The response will look something like this
  #
  # {
  #   "responseHeader":{
  #     "status":0,
  #     "QTime":0,
  #     "params":{
  #      "q":"author:victor",
  #       "fl":"id,title,author"}},
  #   "response":{"numFound":36,"start":0,"docs":[
  #     {
  #       "id":"00011719",
  #       "author":["Flanagan, Alice K."],
  #       "title":["Teachers /"]},
  #     {
  #       ... 9 more results }
  #   ]}
  # }
  #
```

Notice the query parameter `q` in the previous command explicitly asks to search in the `title` field.

Now, let's ask for documents where the `title` includes the word "teachers" **or** the `author` includes the word "Alice".

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teachers+author:Alice"
```

As we saw in the previous example, by default, Solr searches for either of the terms. If we want to force that both conditions are matches we must explicitly use the `AND` operator:


```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teaching+AND+author:Alice"
```

## Ranking of documents

When Solr finds documents that match the query it ranks them so that the most relevant documents show up first.

Let's say that we want documents where either the `title` or the `author` have the word "west"

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:west%20author:west"
```

If we want to boost the documents where the `author` have the word "west" ahead of the documents where "west" was found in the `title` we can indicate this to Solr as follow `title:west author:west^5` (notice the `^5` to boost the `author` field)

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:west%20author:west^5"
```

Notice how documents where the `author` is named "West" come first, but we still get documents where the `title` includes the word "West".


## Other parameters
There is a large number of parameters that you can pass to Solr when querying for documents but these are some of the most common:

* q: search query
* fl: list of fields to return
* start: row to start (default to 0)
* rows: number of documents/rows to return (default to 10)
* sort: fields to sort the result by

title_txt_en:"high school"
title_txt_en:"school high"
title_txt_en:"school high"~3

title_txt_en:"grammar high school"~3

title:"high school"
title:"high school teachers"
title:"teachers high school"~3

title_txt_en:"philosophy of history"
title_txt_en:"philosophy of history"~3
title_txt_en:"philosophy of history"~10


## Where to find more
Solr Query Syntax: http://yonik.com/solr/query-syntax/
