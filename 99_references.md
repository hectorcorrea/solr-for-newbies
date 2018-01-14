# Sample data

Files `data/books.json` and `data/books2.json` contain 10,000 books each taken from Library of Congress' [MARC Distribution Services](https://www.loc.gov/cds/products/marcDist.php). Both files have the exact same data but in `data/books2.json` the field names have been adjusted to allow Solr to assign a more appropriate field type to each field.

TODO: document how I created `data/books.json` from the original MARC data.

TODO: Do I need the larger set with 250K books?


# Sources and where to find more

* [Solr Reference Guide](https://lucene.apache.org/solr/guide/7_0/)
* [Solr in Action](https://www.worldcat.org/title/solr-in-action/oclc/879605085) by Trey Grainger and Timothy Potter
