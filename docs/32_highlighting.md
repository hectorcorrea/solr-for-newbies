## == Hit highlighting

Another Solr feature is the ability to return a fragment of the document where the match was found for a given search term. This is called [highlighting](https://lucene.apache.org/solr/guide/7_0/highlighting.html
).

Let's say that we search for books where the `author` or the `title` include the word "washington". If we add an extra parameter to the query `hl=on` to enable highlighting the results will include an indicator of what part of the author or the title has the match.

```
$ curl 'http://localhost:8983/solr/bibdata/select?defType=edismax&q=washington&qf=title+author&hl=on'

  #
  # response will include
  #
  # "highlighting":{
  #   "00008929":{
  #     "title":["<em>Michael</em> Jackson /"]},
  #   "00022067":{
  #     "authorsAll":["Chinery, <em>Michael</em>."],
  #     "title":["Partners and parents / by <em>Michael</em> Chinery."]},
  #   "00011434":{
  #     "authorsAll":["Castleman, <em>Michael</em>."]},
  #      
```

Notice how the `highlighting` property includes the `id` of each document in the result (e.g. `00008929`), the field where the match was found (e.g. `authorsAll` and/or `title`) and the text that matched within the field (e.g. `<em>Michael</em> Jackson /"`). You can display this information along with your search results to allow the user to "preview" why each result was rendered.
