## Searching (more advanced)

TODO: flesh out this section

pf

pf (phrase field) is for boosting based on proximity of the search terms within the document. I think is related to another field called proximity slop (ps).

The "p" is for "phrase" or "proximity" boosting. "pf" doesn't change what documents match, but gives a boost if all of the terms occur next to or near each other, based on "ps" (phrase/proximity slop.) http://grokbase.com/t/lucene/solr-user/137tqgw12c/difference-between-qf-and-pf-parameters
