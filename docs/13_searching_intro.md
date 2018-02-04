## == Searching for documents

Now that we have added a few documents to our `bibdata` core we can query Solr for those documents. In a subsequent section we'll explore more advanced searching options and how our schema definition is key to enable different kind of searches, but for now we'll start with a few basic searches to get familiar with the way querying works in Solr.

If you look at the content of the `books.json` file that we imported into our `bibdata` core you'll notice that the documents have the following fields:

* **id**: string to identify each document ([MARC](https://www.loc.gov/marc/bibliographic/) 001)
* **author**: string for the main author (MARC 100a)
* **authorDate**: date for the author (MARC 100d)
* **authorFuller**: title of the book (MARC 100q)
* **authorsOther**: list of other authors (MARC 700a)
* **title**: title of the book (MARC 245ab)
* **responsibility**: statement of responsibility (MARC 245c)
* **publisher**: publisher name (MARC 260a)
* **urls_ss**: URLs (MARC 856u)
* **subjects**: an array of subjects (MARC 650a)
* **subjectsForm**: (MARC 650v)
* **subjectsGeneral**: (MARC 650x)
* **subjectsChrono**: (MARC 650y)
* **subjectsGeo**: (MARC 650z)


### === Fetching data

To fetch data from Solr we make an HTTP request to the `select` handler. For example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*'
```

There are many parameters that we can pass to this handler to define what documents we want to fetch and what fields we want to fetch.


### === Selecting what fields to fetch

We can use the `fl` parameter to indicate what fields we want to fetch. For example to request the `id` and the `title` of the documents we would use `fl=id,title` as in the following example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*&fl=id,title'
```

Note: When issuing the commands via cURL (as in the previous example) make sure that the fields are separated by a comma *without any spaces in between them*. In other words make sure the URL says `fl=id,title` and not `fl=id,` `title`. If the parameter includes spaces Solr will not return any results and it won't give you a visible error either!

Try adding and removing some other fields to this list, for example, `fl=id,author,title` or `fl=id,title,author,subjects`


### === Filtering the documents to fetch

In the previous examples you might have seen an inconspicuous `q=*` parameter in the URL. The `q` (query) parameter tells Solr what documents to retrieve. This is somewhat similar to the `WHERE` clause in a SQL SELECT query.

If we want to retrieve all the documents we can just pass `q=*`. But if we want to filter we can use the following syntax: `q=field:value` to filter documents where a specific field has a particular value. For example, to include only documents where the `title` has the word "teachers" we would use `q=title:teachers`:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teachers'
```

We can request filter by many different fields, for example to request documents where the `title` includes the word "teachers" **or** the `author` includes the word "Alice" we would use `q=title:teachers author:Alice`

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teachers+author:Alice'
```

As we saw in the previous example, by default, Solr searches for either of the terms. If we want to force that both conditions are matched we must explicitly use the `AND` operator in the `q` value as in `q=title:teachers AND author:Alice`

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:teachers+AND+author:Alice'
```

Now let's try something else. Let's issue a search for books where the title says "school teachers" using `q=title:"school teachers"`

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=title:"school+teachers"'

  # the results will include   
  # {
  #   "id":"00010001",
  #   "title":["... : strategies for middle and high school teachers /"]},
  # {
  #   "id":"00020575",
  #   "title":["... Sunday school teachers ... /"]},
  # {
  #   "id":"00011238",
  #   "title":["... solutions for middle and high school teachers /"]}]
  #
```

Notice how all three results have the term "school teachers" somewhere on the title. Now let's issue a slightly different query using `q=title:"school teachers"~3` to indicate that we want the words "school" and "teachers" to be present in the `title` but they can be 3 words apart (notice the `~3`):

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=title:"school+teachers"~3'
```

The result for this query will include a new book with title "Aids to teachers of School chemistry" which includes both terms (school and teachers) but the order does not matter as long as they are close to each other.

One other thing. When searching multi-word keywords for a given field make sure the keywords are surrounded by quotes, for example make sure to use `q=title:"school teachers"` and not `q=title:school teachers`. The later will execute a search for "school" in the `title` field and "teachers" in the `_text_` field.

You can validate this by running the query and passing the `debugQuery` flag and seeing the `parsedquery` value. For example in the following command we surround both search terms in quotes:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&debugQuery=on&q=title:"school+teachers"' | grep parsedquery

  # will show
  # "parsedquery":"PhraseQuery(title:\"school teachers\")",
  #
```

whereas in the following command we don't:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&debugQuery=on&q=title:school+teachers' | grep parsedquery

  # will show
  # "parsedquery":"title:school _text_:teachers",
  #
```


### === Getting facets

When we issue a search Solr is able to return facet information about the data in our core. This is a built-in feature of Solr and easy to use, we just need to include the `facet=on` and the `facet.field` parameter with the name of the field that we want to facet the information on.

For example, to search for all documents with title "education" (`q=title:education`) and retrieve facets (`facet=on`) based on the `subjects` field (`facet.field=subjects`) we'll use a query like this:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:education&facet=on&facet.field=subjects'

  # response will include something like this
  #
  # "facet_counts":{
  #   "facet_queries":{},
  #   "facet_fields":{
  #     "subjects":[
  #       "education",45,
  #       "and",18,
  #       "higher",12,
  #       "colleges",7,
  #       "in",7,
  #       "universities",7,
  #       "educational",6,
  #       "moral",4,
  #       "social",4,
  #       "teachers",4,
  #
```

You might notice a few extraneous subjects in the list (like the words "and", and "in") and you can also guess that "higher" should really be "higher education". We'll review later why we are getting the *tokenized* version of the subject rather than the actual subject values. For now, try issuing the previous command but using the `subjects_str` field instead:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title,author&q=title:education&facet=on&facet.field=subjects_str'

  # response will include something like this
  #
  # "facet_counts":{
  #   "facet_queries":{},
  #   "facet_fields":{
  #     "subjects_str":[
  #       "Education, Higher",10,
  #       "Education",7,
  #       "Universities and colleges",6,
  #       "Educational equalization",3,
  #       "Moral education",3,
  #       "Women",3,
  #
```
