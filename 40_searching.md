# Searching for documents

When we issue a search to Solr we pass the search parameters in the query string. In previous examples we passed values in the `q` parameter to indicate the values that we want to search for and `fl` to indicate what fields we want to retrieve. For example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&fl=id,title'
```

In some instances we passed rather sophisticated values for these parameters, for example we used `q=title:"school teachers"~3` when we wanted to search for books with the words "school" and "teachers" in the title within three words of each other.

The components in Solr that parse these parameters are called Query Parsers. Their job is to extract the parameters and create a query that Lucene can understand. Remember that Lucene is the search engine underneath Solr.


## Query Parsers

Out of the box Solr comes with three query parsers: Standard, DisMax, and Extended DisMax (eDisMax). Each of them has its own advantages and disadvantages.

* The [Standard](https://lucene.apache.org/solr/guide/7_0/the-standard-query-parser.html) query parser (aka the Lucene Parser) is the default parser and is very powerful, but it's rather unforgiving if there is an error in the query submitted to Solr. This makes the Standard query parser a poor choice if we want to allow user entered queries, particular if we allow queries with expressions like AND or OR operations.

* The [DisMax](https://lucene.apache.org/solr/guide/7_0/the-dismax-query-parser.html) query parser (DisMax) on the other hand was designed to handle user entered queries and is very forgiving on errors when parsing a query, however this parser only supports simple query expressions.

* The [Extended DisMax](https://lucene.apache.org/solr/guide/7_0/the-extended-dismax-query-parser.html) (eDisMax) query parser is an improved version of the DisMax parser that is also very forgiving to errors when parsing user entered queries and like the Standard query parser supports complex query expressions.

The selection of the parser has practical implication for us as developers of end user applications. For example, by using the eDisMax parser the syntax of the queries that we pass to Solr is a bit more user friendly than if we use the Standard parser.

For example, let's say that we want to search for all books where "George Washington" exists in the `title` or in the `authorsAll` field, and we want to rank higher books where "George Washington" was the author than when he is referenced in the title.

Using the *Standard* query parser we will need to pass all this information in the `q` parameter to Solr as follows: `q=title:"george washington" authorsAll:"george washington"^10` which we could easily do as developers but it would be rather outrageous to ask an end user to enter such syntax.

By using the *eDisMax* parser we could pass a much simpler `q` parameter to Solr `q="george washington"` and send a separate parameter to configure the fields to search on and their boosting value `qf=title author^10`. This is possible because the eDisMax parameter supports the `qf` parameter but the Standard parameter does not.

The rest of the examples in this section are going to use the eDisMax parser, notice the `defType=edismax` in our queries to Solr to make this selection. As we will see later on this tutorial you can also set the default query parser of your Solr core to use eDisMax by updating the `defType` parameter in your `solrconfig.xml` so that you don't have to explicitly set it on every query.


## Basic searching in Solr
The number of search parameters that you can pass to Solr is rather large and, as we've noticed, they also depend on what query parser you are using.

To see a list a comprehensive list of the parameters that apply to all parsers take a look at the [Common Query Parameters](https://lucene.apache.org/solr/guide/7_0/common-query-parameters.html#common-query-parameters) and the [Standard Query Parser](https://lucene.apache.org/solr/guide/7_0/the-standard-query-parser.html) sections in the Solr Reference Guide.

Below are some of the parameters that are supported by all parsers:

* `defType`: Query parser to use (default is `lucene`, other possible values are `dismax` and `edismax`)
* `q`: Search query, the basic syntax is `field:"value"`.
* `sort`: Sorting of the results (default is `score desc`, i.e. higher ranked document first)
* `rows`: Number of documents to return (default is `10`)
* `start`: Index of the first document to result (default is `0`)
* `fl`: List of fields to return in the result.
* `fq`: Filters results without affecting the scoring.

Below are a few sample queries to show these parameters in action. Notice that spaces are URL encoded as `+` in the commands below, you do not need to encode them if you are submitting these queries via the [Solr Admin interface](http://localhost:8983/solr/#/bibdata/query) in your browser.

* Retrieve the first 10 documents where the `title` includes the word "washington"
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:washington'
```

* The next 15 documents for the same query (notice the `start` and `rows` parameters)
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:washington&start=10&rows=15'
```

* Retrieve the `id` and `title` (notice the `fl` parameter) where the title includes the words "women writers" but allowing for a word in between (e.g. "women nature writers")
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:"women+writers"~3&fl=id,title'
```

* Documents that have a main author (`author:*` means any author)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=author:*'
```

* Documents that do *not* have an author (notice the `NOT` before the author field to negate the expression)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=NOT+author:*'
```

* Documents where at least one of the subjects starts with "com" (notice `subjects:com*`)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=subjects:com*'
```

* Documents where title include "story" *and* at least one of the subjects is "women" (notice that both search conditions are indicated in the `q` parameter)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=title:story+AND+subjects:women'
```

* Similar to the previous query, documents where title include "story" *and* at least one of the subjects is "women", but *without considering the subject in the ranking of the results* (notice that subjects is filtered via the `fq` parameter)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=title:story&fq=subjects:women'
```


## q vs fq paramter
q and fq
q (query) and fq (filter query) use the same syntax but have different meanings.

Solr uses fq to filter results, and q to filter results and provide rankings.

Use fq for machine generated filters (e.g. visibility:all) and f for user provided keywords (e.g. title=rome.) There can be many fq but only one q values in a search request.

fq are good candidates for caching because they are not subject to arbitrary user entered parameters. Plus they are not ranked.

At runtime Solr applies first the fq to get a set of documents and then applies q on top of that set to filter even more and rank.

Source: Solr in Action, pages 210-215


## Filtering with ranges

...

## AND/OR/NOT expressions

...


## edismax options


qf
qf (query field) used to boost the value of certain fields, for example:

qf=title^100
qf=text^10

will rank higher documents where the match is in the title than when the match is in the text.

https://www.triquanta.nl/blog/what-fq-short-summary-solr-query-fields


df: default field, default is `_text_`, only one allowed (use a copy field if you need many)




## Facets
...



## Searching (more advanced)
pf
pf (phrase field) is for boosting based on proximity of the search terms within the document. I think is related to another field called proximity slop (ps).

The "p" is for "phrase" or "proximity" boosting. "pf" doesn't change what documents match, but gives a boost if all of the terms occur next to or near each other, based on "ps" (phrase/proximity slop.) http://grokbase.com/t/lucene/solr-user/137tqgw12c/difference-between-qf-and-pf-parameters








## Score calculation


http://www.openjems.com/solr-lucene-score-tutorial/ (dead link -- see internet archive)

https://stackoverflow.com/questions/16126963/subquery-scoring-and-coord-in-edismax-ranking-in-solr
