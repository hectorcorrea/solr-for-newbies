## Sources and where to find more

* [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/)
* [Solr in Action](https://www.worldcat.org/title/solr-in-action/oclc/879605085) by Trey Grainger and Timothy Potter
* [Relevant search with applications for Solr and Elasticsearch](http://www.worldcat.org/title/relevant-search-with-applications-for-solr-and-elasticsearch/oclc/980984111) by Doug Turnbull and John Berryman


### Sample data

File `books.json` contains 10,000 books taken from Library of Congress' [MARC Distribution Services](https://www.loc.gov/cds/products/marcDist.php).

The steps to create the `books.json` file from the MARC data are as follow:

* Download file `BooksAll.2014.part01.utf8.gz` from https://www.loc.gov/cds/downloads/MDSConnect/BooksAll.2014.part01.utf8.gz.
* Unzip it: `gzip -d BooksAll.2014.part01.utf8.gz`
* Process the unzipped file with [marcli](https://github.com/hectorcorrea/marcli) with the following command: `./marcli --file BooksAll.2014.part01.utf8 -format solr > books.json`

The MARC file has 250,000 books and therefore the resulting `books.json` will have 250,000 too. For the purposes of the tutorial I manually truncated the file to include only the first 10,000 books.

`marcli` is a small utility program that I wrote in Go to parse MARC files. If you are interested in the part that generates the JSON out of the MARC record take a look at the [processorSolr.go](https://github.com/hectorcorrea/marcli/blob/master/processorSolr.go) file. 
