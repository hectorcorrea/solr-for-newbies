Solr
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

pf
pf (phrase field) is for boosting based on proximity of the search terms within the document. I think is related to another field called proximity slop (ps).

The "p" is for "phrase" or "proximity" boosting. "pf" doesn't change what documents match, but gives a boost if all of the terms occur next to or near each other, based on "ps" (phrase/proximity slop.) http://grokbase.com/t/lucene/solr-user/137tqgw12c/difference-between-qf-and-pf-parameters


## Get list of fields
http://stackoverflow.com/questions/3211139/solr-retrieve-field-names-from-a-solr-index


## Score calculation


http://www.openjems.com/solr-lucene-score-tutorial/

https://stackoverflow.com/questions/16126963/subquery-scoring-and-coord-in-edismax-ranking-in-solr
