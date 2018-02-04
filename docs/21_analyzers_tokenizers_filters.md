## Analyzers, Tokenizers, and Filters  

When we looked at the definition of the `text_general` field type we saw a couple of values that pointed to `tokenizer` and `filters` under the `indexAnalyzer` and `queryAnalyzer` properties.

The `indexAnalyzer` section defines the transformations to perform *as the data is indexed* in Solr and `queryAnalyzer` defines transformations to perform *as we query for data* out of Solr. It's important to notice that the output of the `indexAnalyzer` affects the terms *indexed*, but not the value *stored*. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/analyzers.html) says:

    The output of an Analyzer affects the terms indexed in a given field
    (and the terms used when parsing queries against those fields) but
    it has no impact on the stored value for the fields. For example:
    an analyzer might split "Brown Cow" into two indexed terms "brown"
    and "cow", but the stored value will still be a single String: "Brown Cow"

Below is how the analyzers for the `text_general` field type are defined in a standard Solr installation.

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes/text_general

  # Response includes indexAnalyzer's tokenizer and filters:
  #
  #     "indexAnalyzer":{
  #       "tokenizer":{
  #         "class":"solr.StandardTokenizerFactory"
  #       },
  #       "filters":[
  #         {
  #           "class":"solr.StopFilterFactory",
  #           "words":"stopwords.txt",
  #           "ignoreCase":"true"
  #         },
  #         {
  #           "class":"solr.LowerCaseFilterFactory"
  #         }
  #       ]
  #     },
  #
  # and queryAnalyzer's tokenizer and filters:
  #
  #     "queryAnalyzer":{
  #       "tokenizer":{
  #         "class":"solr.StandardTokenizerFactory"
  #       },
  #       "filters":[
  #         {
  #           "class":"solr.StopFilterFactory",
  #           "words":"stopwords.txt",
  #           "ignoreCase":"true"
  #         },
  #         {
  #           "class":"solr.SynonymGraphFilterFactory",
  #           "expand":"true",
  #           "ignoreCase":"true",
  #           "synonyms":"synonyms.txt"
  #         },
  #         {
  #           "class":"solr.LowerCaseFilterFactory"
  #         }
  #       ]
  #     }
```

When a value is *indexed* for a particular field the value is first passed to the `tokenizer` and then to the `filters` defined in the `indexAnalyzer` section for that field type. Similarly, when we *query* for a value in a given field the value is first processed by the `tokenizer` and then by the `filters` defined in the `queryAnalyzer` section for that field.

Notice that the tokenizer and filters applied at index time can be different from the ones applied at query time, as it is the case in the `text_general` field type above (notice the extra filter on the `queryAnalyzer` section.)


### Tokenizers

For most purposes we can think of a tokenizer as something that splits a given text into individual tokens or words. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/tokenizers.html) defines Tokenizers as follows:

    Tokenizers are responsible for breaking
    field data into lexical units, or tokens.

For example if we give the text "hello world" to a tokenizer it might split the text into two tokens like "hello" and "word".

Solr comes with several [built-in tokenizers](https://lucene.apache.org/solr/guide/7_0/tokenizers.html) that handle a variety of data. For example if we expect a field to have information about a person's name the [Standard Tokenizer](https://lucene.apache.org/solr/guide/7_0/tokenizers.html#standard-tokenizer) might be appropriated for it. However, for a field that contains e-mail addresses the [UAX29 URL Email Tokenizer](https://lucene.apache.org/solr/guide/7_0/tokenizers.html#uax29-url-email-tokenizer) might be a better option.

I believe you can only have [one tokenizer per analyzer](https://lucene.apache.org/solr/guide/7_0/tokenizers.html)


### Filters

Whereas a `tokenizer` takes a string of text and produces a set of tokens, a `filter` takes a set of tokens, process them, and produces a different set of tokens. The [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/about-filters.html) says that

    in most cases a filter looks at each token in the stream sequentially
    and decides whether to pass it along, replace it or discard it.

Notice that unlike tokenizers, whose job is to split text into tokens, the job of filters is a bit more complex since they might replace the token with a new one or discard it altogether.

Solr comes with many [built-in Filters](https://lucene.apache.org/solr/guide/7_0/filter-descriptions.html) that we can use to perform useful transformations. For example the ASCII Folding Filter converts non-ASCII characters to their ASCII equivalent (e.g. "México" is converted to "Mexico"). Likewise the English Possessive Filter removes singular possessives (trailing 's) from words. Another useful filter is the Porter Stem Filter that calculates word stems using English language rules (e.g. both "jumping" and "jumped" will be reduced to "jump".)


### Putting it all together

If we look at the tokenizer and filters defined for the `text_general` field type at *index time* we would see that we are tokenizing with the `StandardTokenizer` and filtering with the `StopFilter` and the `LowerCaseFilter` filters.

Notice that the at *query time* an extra filter, the `SynonymGraphFilter`, is applied for this field type.

If we *index* the text "The television is broken!" the tokenizer and filters defined in the `indexAnalyzer` will transform this text to four tokens: "the", "television", "is", and "broken". Notice how the tokens were lowercased ("The" became "the") and the exclamation sign was dropped.

Likewise, if we *query* for the text "The TV is broken!" the tokenizer and filters defined in the `queryAnalyzer` will convert the text to the following tokens: "the", "television", "televisions", "tvs", "tv", "is", and "broken". Notice that an additional transformation was done to this text, namely, the word "TV" was expanded to four synonyms. This is because the `queryAnalyzer` uses the `SynonymGraphFilter` and a standard Solr configuration comes with those four synonyms predefined in the `synonyms.txt` file.
