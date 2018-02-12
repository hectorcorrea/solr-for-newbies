## Spellchecker

Solr provides spellcheck functionality out of the box that we can use to help users when they misspell a word in their queries. For example, if a user searches for "Washingon" (notice the missing "t") most likely Solr will return zero results, but with the spellcheck turned on Solr is able to suggest the correct spelling for the query (i.e. "Washington").

In our current `bibdata` core a search for "Washingon" will return zero results:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=title:washingon'

  #
  # response will indicate
  # {
  # "responseHeader":{
  #   "status":0,
  #  "params":{
  #    "q":"title:washingon",
  #    "fl":"id,title"}},
  # "response":{"numFound":0,"start":0,"docs":[]
  # }}
  #
```

Spellchecking is configured under the `/select` request handler in `solrconfig.xml`. To enable it we need to update the `defaults` settings and enable the `spellcheck` search component. To do this update the `/select` request handler as follows:

```
<requestHandler name="/select" class="solr.SearchHandler">
  <lst name="defaults">
    <str name="echoParams">explicit</str>
    <int name="rows">10</int>
    <int name="rows">10</int>
    <str name="defType">edismax</str>
    <str name="spellcheck">on</str>
    <str name="spellcheck.extendedResults">false</str>
    <str name="spellcheck.count">5</str>
    <str name="spellcheck.alternativeTermCount">2</str>
    <str name="spellcheck.maxResultsForSuggest">5</str>
    <str name="spellcheck.collate">true</str>
    <str name="spellcheck.collateExtendedResults">true</str>
    <str name="spellcheck.maxCollationTries">5</str>
    <str name="spellcheck.maxCollations">3</str>
  </lst>

  <arr name="last-components">
    <str>spellcheck</str>
  </arr>
</requestHandler>
```

The `spellcheck` component indicated above is already defined in the `solrconfig.xml` with the following defaults.

```
<searchComponent name="spellcheck" class="solr.SpellCheckComponent">
  <str name="queryAnalyzerFieldType">text_general</str>
  <lst name="spellchecker">
    <str name="name">default</str>
    <str name="field">_text_</str>
    <str name="classname">solr.DirectSolrSpellChecker</str>
    ...
  </lst>
</searchComponent
```

Notice how by default it will use the `_text_` field for spellcheck. The `_text_` field would be a good field to use if we were populating it, but we aren't in our current configuration. Instead let's update this setting to use the `title` field instead.

Once these changes have been made to the `solr_config.xml` we must reload our core for the changes to take effect:

```
$ curl 'http://localhost:8983/solr/admin/cores?action=RELOAD&core=bibdata'

  #
  # {
  #   "responseHeader":{
  #      "status":0,
  #      "QTime":10392
  #   }
  # }
  #
  
```

Now that our `bibdata` core has been configured to use spellcheck let's try out misspelled query again:

```
$ curl 'http://localhost:8983/solr/bibdata/select?fl=id,title&q=title:washingon'

  #
  # response will indicate
  #
  # {
  #   "responseHeader":{
  #     "response":{"numFound":0,"start":0,"docs":[]
  #   },
  #   "spellcheck":{
  #     "suggestions":[
  #       "washingon",{
  #         "numFound":1,
  #         "startOffset":6,
  #         "endOffset":15,
  #         "suggestion":["washington"]
  #     }],
  #     "collations":[
  #       "collation",{
  #         "collationQuery":"title:washington",
  #         "hits":21,
  #         "misspellingsAndCorrections":[
  #         "washingon","washington"]}]
  #   }
  # }
  #
```

Notice that even though we got zero results back, the response now includes a `spellcheck` section *with the words that were misspelled and the suggested spelling for it*. We can use this information to alert the user that perhaps they misspelled a word or perhaps re-submit the query with the correct spelling.
