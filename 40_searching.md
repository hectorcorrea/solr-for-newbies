# Searching for documents (part II)

When we issue a search to Solr we pass the search parameters in the query string. In previous examples we passed values in the `q` parameter to indicate the values that we want to search for and `fl` to indicate what fields we want to retrieve. For example:

```
$ curl "http://localhost:8983/solr/bibdata/select?q=*&fl=id,title"
```

In some instances we passed rather sophisticated values for these parameters, for example we used `q=title:"school teachers"~3` when we wanted to search for books with the words "school" and "teachers" in the title within three words of each other.

The components in Solr that analyze theses parameters and process them are called Query Parsers.


## Query Parsers

Out of the box Solr comes with three query parsers: Standard, DisMax, and Extended DisMax (eDisMax). Each of them has its own advantages and disadvantages.

* The [Standard](https://lucene.apache.org/solr/guide/7_0/the-standard-query-parser.html) query parser (aka the Lucene Parser) is the default parser and it's very powerful but it's rather unforgiving if there is an error in the query submitted to Solr. This makes it a poor choice if we want to allow user entered queries, particular queries with expressions (like AND or OR operations)

* The [DisMax](https://lucene.apache.org/solr/guide/7_0/the-dismax-query-parser.html) query parser (DisMax) on the other hand was designed to handle user entered queries and is very forgiving on errors when parsing a query, however this parser supports only simple query expressions.

* The [Extended DisMax](https://lucene.apache.org/solr/guide/7_0/the-extended-dismax-query-parser.html) (eDisMax) query parser is an improved version of the DisMax parser that is also very forgiving to parsing errors but supports complex query expressions.

The selection of the parser has practical implication for us as developers of end user applications. For example, by using the eDisMax parser the syntax of the queries that we pass to Solr is a bit more user friendly than if we use the Standard parser. Let's say that we want to search for all books where the `title` has the word "George" or the `author` was somebody named "George" and we want to rank higher books where "George" was found in the title than when it was found in the author field.

Using the *Standard* query parser we will need to pass all this information in the `q` parameter to Solr as follows: `q=title:george^200 OR author:george^4` which we could easily do as developers but it would be rather outrageous to ask an end user to enter such syntax.

By using the *eDisMax* parser we could pass a much simpler `q` parameter to Solr `q=george` and send a separate parameter to configure the field boosting `qf=title^200 author^4`. This is possible because the eDisMax parameter supports the `qf` parameter but the Standard parameter does not.

TODO: elaborate on how easy is to use `q=george AND washington` using eDisMax as opossed to the Standard parser.

The rest of the examples in this section are going to use the eDisMax parser, notice the `defType=edismax` in our queries to Solr to make this selection.

## Basic searching
Searching in Solr ca
In a previous sections we have run a few queries to get information out of Solr but we haven't really elaborated on what each of the parameters do and what else we can do when searching for documents in Solr.



* q: search query (for user entered terms)
* fq: filter query (for known values, e.g. when filtering by a facet value)
* fl: list of fields to return
* start: row to start (default to 0)
* rows: number of documents/rows to return (default to 10)
* sort: fields to sort the result by


q and fq
q (query) and fq (filter query) use the same syntax but have different meanings.

Solr uses fq to filter results, and q to filter results and provide rankings.

Use fq for machine generated filters (e.g. visibility:all) and f for user provided keywords (e.g. title=rome.) There can be many fq but only one q values in a search request.

fq are good candidates for caching because they are not subject to arbitrary user entered parameters. Plus they are not ranked.

At runtime Solr applies first the fq to get a set of documents and then applies q on top of that set to filter even more and rank.

Source: Solr in Action, pages 210-215

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
