## Facets
One of the most popular features of Solr is the concept of *facets*. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/faceting.html) defines it as:

    Faceting is the arrangement of search results into categories
    based on indexed terms.

    Searchers are presented with the indexed terms, along with numerical
    counts of how many matching documents were found for each term.
    Faceting makes it easy for users to explore search results, narrowing
    in on exactly the results they are looking for.

You can easily get facet information from a query by selecting what field (or fields) you want to use to generate the categories and the counts. The basic syntax is `facet=on` followed by `facet.field=name-of-field`. For example to facet our dataset by *subjects* we would use the following syntax: `facet.field=subjects_str` as in the following example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&facet=on&facet.field=subjects_str'

  # result will include
  #
  # "facet_counts":{
  #  "facet_queries":{},
  #  "facet_fields":{
  #    "subjects_str":[
  #      "Women",179,
  #      "African Americans",159,
  #      "Christian life",119,
  #      "Large type books",110,
  #      "Indians of North America",104,
  #      "English language",88,
  #      ...
  #    
```

You might have noticed that we are using the `string` representation of the subjects (`subjects_str`) to generate the facets rather than the `text_general` version stored in the `subjects` field. This is because, as the Solr Reference Guide indicates facets are calculated "based on indexed terms". The indexed version of the `subject` field is tokenized whereas the indexed version of `subject_str` is the entire string.  

You can indicate more than one `facet.field`, for example to get facets for publisher and subjects we would pass `facet.field=subjects_str&facet.field=publisher_str`

There are several extra parameters that you can pass to Solr to customize how many facets are returned on result set. For example, if you want to list only the top 20 publishers in the facets rather than all of them you can indicate this with the following syntax: `f.publisher_str.facet.limit=20`. You can also filter only get facets that have *at least* certain number of matches, for example only publishers that have at least 100 books `f.publisher_str.facet.mincount=100` as shown the following example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&facet=on&facet.field=publisher_str&f.publisher_str.facet.mincount=100&f.publisher_str.facet.limit=20'
```

You can also facet **by multiple fields at once** this is called [Pivot Faceting](https://lucene.apache.org/solr/guide/7_0/faceting.html#pivot-decision-tree-faceting). The way to do this is via the `facet.pivot` parameter. This parameter allows you to list the fields that should be used to facet the data, for example to facet the information *by subject and then by publisher* you could issue the following command:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&facet=on&facet.pivot=subjects_str,publisher_str&facet.limit=5'

  #
  # response will include facets organized as follows:
  #
  # "facet_counts":{
  #  "facet_pivot":{
  #    "subjects_str,publisher_str":[
  #      {
  #        "field":"subjects_str",
  #        "value":"Women",
  #        "count":179,
  #        "pivot":[
  #          { "field":"publisher_str", "value":"New York :", "count":24},
  #          { "field":"publisher_str", "value":"Berkeley Heights, NJ :", "count":19},
  #          { "field":"publisher_str", "value":"Minneapolis :", "count":11}
  #        ]
  #      },
  #      {
  #        "field":"subjects_str",
  #        "value":"African Americans",
  #        "count":159,
  #        "pivot":[
  #          { "field":"publisher_str", "value":"Berkeley Heights, NJ :", "count":35},
  #          { "field":"publisher_str", "value":"New York :", "count":22},
  #          { "field":"publisher_str", "value":"Chanhassen, MN :", "count":9}
  #        ]
  #      }
  #    ]
  #  ...
  #
```
