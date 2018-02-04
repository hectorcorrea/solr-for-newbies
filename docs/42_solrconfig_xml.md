## == Core-specific configuration

One of the most important configuration files for a Solr core is `solrconfig.xml` located in the configuration folder for the core. In our `bibdata` core it would be located under  `~/solr-7.1.0/server/solr/bibdata/conf/solr_config.xml`.

A default `solrconfig.xml` file is about 1300 lines of heavily documented XML. We won't need to make changes to most of the content of this file, but there are a couple of areas that are worth knowing about: request handlers and search components.


### === Request Handlers

When we submit a request to Solr the request is processed by a request handler. Throughout this tutorial all our queries to Solr have gone to a URL that ends with `/select`, for example:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*'
```

The `/select` in the URL points to a request handler defined in `solrconfig.xml`. If we look at the content of this file you'll notice a definition like this:

```
$ cat ~/solr-7.1.0/server/solr/bibdata/conf/solrconfig.xml

  #
  # notice the "/select" in this requestHandler definition
  #
  # <requestHandler name="/select" class="solr.SearchHandler">
  #   <lst name="defaults">
  #     <str name="echoParams">explicit</str>
  #     <int name="rows">10</int>
  #   </lst>
  # </requestHandler>
  #
```

We can make changes to this section to indicate that we want to use the eDisMax query parser (`defType`) by default and set the default query fields (`qf`) to title and author. To do so we could update the "defaults" section as follows:

```
  <lst name="defaults">
    <str name="echoParams">explicit</str>
    <int name="rows">10</int>
    <str name="defType">edismax</str>
    <str name="qf">title author</str>
  </lst>
```

We'll need to reload your core for changes to the `solrconfig.xml` to take effect.

Be careful, an incorrect setting on this file can take our core down or cause queries to give unexpected results. For example, entering the `qf` value as `title, author` (notice the comma to separate the fields) will cause Solr to ignore this parameter.  

The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/requesthandlers-and-searchcomponents-in-solrconfig.html) has excellent documentation on what the values for a request handler mean and how we can configure them.


### === LocalParams and dereferencing

In addition to the standard parameters in a request handler we can also define custom settings and use them in our search queries. For example is possible to define a new setting (`custom_search_field`) to group a list of fields and their boost values as shown below:

```
<requestHandler name="/select" class="solr.SearchHandler">
  <lst name="defaults">
    ...
  </lst>
  <str name="custom_search_field">
    title^10
    authorsAll^5
    subjects
  </str>
</requestHandler>
```

We can then use this new setting in our queries by using the [Local Parameters](https://lucene.apache.org/solr/guide/7_0/local-parameters-in-queries.html#parameter-dereferencing) and [Dereferencing](https://lucene.apache.org/solr/guide/7_0/local-parameters-in-queries.html#parameter-dereferencing) features of Solr.

The syntax to use local parameters and dereferencing look a bit scary at first since you have to pass your parameters in the following format: `{! key=value}` where `key` is the parameter that you want to pass and `value` the value to use for that parameter. Dereferencig (asking Solr use a pre-existing value rather than a literal) is triggered by prefixing the `value` with a `$` as in `{! key=$value}`

For example to use our newly defined `custom_search_field` in a query we could pass the following to Solr:

```
q={! qf=$custom_search_field}teachers
```

You can see an example of how this is used in a Blacklight application in the following [blog post](https://library.brown.edu/DigitalTechnologies/solr-localparams-and-dereferencing/).


### === Search Components

Request handlers in turn use search components to execute different operations on a search. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/requesthandlers-and-searchcomponents-in-solrconfig.html) defines search components as:

    A search component is a feature of search, such as highlighting or faceting.
    The search component is defined in solrconfig.xml separate from the request
    handlers, and then registered with a request handler as needed.

You can find the definition of the search components in the `solrconfig.xml` by looking at the `searchComponent` elements defined in this file. For example, in our `solrconfig.xml` there is a section like this for the highlighting feature that we used before:

```
<searchComponent class="solr.HighlightComponent" name="highlight">
  <highlighting>
    ... lots of other properties are define here...
    <formatter name="html"
      default="true"
      class="solr.highlight.HtmlFormatter">
      <lst name="defaults">
        <str name="hl.simple.pre"><![CDATA[<em>]]></str>
        <str name="hl.simple.post"><![CDATA[</em>]]></str>
      </lst>
    </formatter>
    ... lots of other properties are define here...
```

Notice that the HTML tokens (`<em>` and `</em>`) that we saw in the highlighting results in  previous section are defined here.

Although search components are defined in `solrconfig.xml` it's a bit tricky to notice their relationship to request handlers in the config because Solr defines a [set of default search components](https://lucene.apache.org/solr/guide/7_0/requesthandlers-and-searchcomponents-in-solrconfig.html#default-components) that are automatically applied *unless we overwrite them*.


### === Solr-wide configuration

Despite its name, file `solrconfig.xml` controls the configuration *for our core*, not for the entire Solr installation. Each core has its own `solrconfig.xml` file.

There is a separate file for Solr-wide configuration settings. In our Solr installation it will be under `~/solr-7.1.0/server/solr/solr.xml`. This file is out of the scope of this tutorial.
