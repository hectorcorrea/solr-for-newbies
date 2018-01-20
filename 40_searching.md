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

By using the *eDisMax* parser we could pass a much simpler `q` parameter to Solr `q="george washington"` and send a separate parameter to configure the fields to search on and their boosting value `qf=title authorsAll^10`. This is possible because the eDisMax parameter supports the `qf` parameter but the Standard parameter does not.

The rest of the examples in this section are going to use the eDisMax parser, notice the `defType=edismax` in our queries to Solr to make this selection. As we will see later on this tutorial you can also set the default query parser of your Solr core to use eDisMax by updating the `defType` parameter in your `solrconfig.xml` so that you don't have to explicitly set it on every query.


## Basic searching in Solr
The number of search parameters that you can pass to Solr is rather large and, as we've noticed, they also depend on what query parser you are using.

To see a list a comprehensive list of the parameters that apply to all parsers take a look at the [Common Query Parameters](https://lucene.apache.org/solr/guide/7_0/common-query-parameters.html#common-query-parameters) and the [Standard Query Parser](https://lucene.apache.org/solr/guide/7_0/the-standard-query-parser.html) sections in the Solr Reference Guide.

Below are some of the parameters that are supported by all parsers:

* `defType`: Query parser to use (default is `lucene`, other possible values are `dismax` and `edismax`)
* `q`: Search query, the basic syntax is `field:"value"`.
* `sort`: Sorting of the results (default is `score desc`, i.e. highest ranked document first)
* `rows`: Number of documents to return (default is `10`)
* `start`: Index of the first document to result (default is `0`)
* `fl`: List of fields to return in the result.
* `fq`: Filters results without calculating a score.

Below are a few sample queries to show these parameters in action. Notice that spaces are URL encoded as `+` in the commands below, you do not need to encode them if you are submitting these queries via the [Solr Admin interface](http://localhost:8983/solr/#/bibdata/query) in your browser.

* Retrieve the first 10 documents where the `title` includes the word "washington" (`q=title:washington`)
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:washington'
```

* The next 15 documents for the same query (notice the `start=10` and `rows=15` parameters)
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:washington&start=10&rows=15'
```

* Retrieve the `id` and `title` (`fl=id,title`) where the title includes the words "women writers" but allowing for a word in between e.g. "women nature writers" (`q=title:"women writers"~3`)
```
$ curl 'http://localhost:8983/solr/bibdata/select?q=title:"women+writers"~3&fl=id,title'
```

* Documents that have a main author (`q=author:*` means any author)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=author:*'
```

* Documents that do *not* have an author (`q=NOT author:*` means author is not present)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=NOT+author:*'
```

* Documents where at least one of the subjects starts with "com" (`q=subjects:com*`)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=subjects:com*'
```

* Documents where title include "story" *and* at least one of the subjects is "women" (`q=title:story AND subjects:women` notice that both search conditions are indicated in the `q` parameter)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=title:story+AND+subjects:women'
```

* Similar to the previous query, documents where title include "story" (`q=title:story`) *and* at least one of the subjects is "women" (`fq=subjects:women`) but *without considering the subject in the ranking of the results* (notice that subjects are filtered via the `fq` parameter in this example)
```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,subjects&q=title:story&fq=subjects:women'
```


## q and fq parameters

Solr supports two different parameters to filter results in a query. One is the Query `q` parameter that we've been using in all our examples. The other is the Filter Query `fq` parameter that we introduced in the last query. Both parameters can be used to filter the documents to return in a query, but there is a key difference between them: `q` calculates scores for the results whereas `fq` does not.

In [Solr in Action](https://www.worldcat.org/title/solr-in-action/oclc/879605085) (p. 211) the authors say:

    So what is the difference between the q and fq parameters?

    fq serves a single purpose: to limit your results to a set
    of matching documents.

    The q parameter, in contrast, serves two purposes:
      * To limit your results to a set of matching documents
      * To supply the relevancy algorithm with a list of terms
        to be used for relevancy scoring

The reason this is important is because values filtered via `fq` can be cached and reused better by Solr in subsequent queries because they don't have a score assigned to them. The authors of Solr in Action recommend using the `q` parameter for values entered by the user and `fq` for values selected from a list (e.g. from a dropdown or a facet in an application)

Both `q` and `fq` use the same syntax for filtering documents (e.g. `field:value`). However you can only have one `q` parameter in a query but you can have many `fq` parameters. Multiple `fq` parameters are `ANDed` (you cannot specify an OR operation among them).


### the qf parameter

The DisMax and eDisMax query parsers provide another parameter, Query Fields `qf`, that should not be confused with the `q` or `fq` parameters. The `qf` parameter is used to indicate the *list of fields* that the search should be executed on along with their boost values.

As we saw in a previous example if we execute a search on multiple fields and give each of them a different boost value the `qf` parameter makes this relatively easily as we can indicate the search terms in the `q` parameter (`q="george washington"`) and list the fields and their boost values separately (`qf=title authorsAll^10`). Remember to select the eDisMax parser (`defType=edismax`) when using the `qf` parameter.

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,authorsAll&q="george+washington"&qf=title+authorsAll^20&defType=edismax'
```


## debugQuery

...


## Ranking of documents

When Solr finds documents that match the query it ranks them so that the most relevant documents show up first. You can provide Solr guidance on what fields are more important to you so that Solr consider this when ranking documents that matches a given query.

Let's say that we want documents where either the `title` or the `author` have the word "west", we would use `q=title:west author:west`

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:west+author:west"
```

Now let's say that we want to boost the documents where the `author` have the word "west" ahead of the documents where "west" was found in the `title`. To this we update the `q` parameter as follow `q=title:west+author:west^5` (notice the `^5` to boost the `author` field)

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:west+author:west^5"
```

Notice how documents where the `author` is named "West" come first, but we still get documents where the `title` includes the word "West".

If want to see why Solr ranked a result higher than another you can look at the `explain` information that Solr returns when passing the `debugQuery=on` parameter, for example:

```
$ curl "http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:west+author:west&debugQuery=on&wt=xml"
```

but be aware that the default `explain` output from Solr is rather convoluted. Take a look at [this blog post](https://library.brown.edu/DigitalTechnologies/understanding-scoring-of-documents-in-solr/) to get primer on how to interpret this information.



## df parameter / configuration

df: default field, default is `_text_`, only one allowed (use a copy field if you need many)


## Filtering with ranges

...

## AND/OR/NOT expressions

...


## Facets

...


## Searching (more advanced)
pf
pf (phrase field) is for boosting based on proximity of the search terms within the document. I think is related to another field called proximity slop (ps).

The "p" is for "phrase" or "proximity" boosting. "pf" doesn't change what documents match, but gives a boost if all of the terms occur next to or near each other, based on "ps" (phrase/proximity slop.) http://grokbase.com/t/lucene/solr-user/137tqgw12c/difference-between-qf-and-pf-parameters


## Where to find more
Searching is a large topic and complex topic. I've found the book "Relevant search with applications for Solr and Elasticsearch" (see references) to be a good conceptual reference with specifics on how to understand and configure Solr to improve search results.
