A few directories of interest in your Solr directory.

* `./bin/`: Scripts to start/stop Solr and post data to it.

* `./dist/`: Contains the Java Archive (JAR) files. These are the binaries that make up Solr.

* `./examples/`: Sample data that Solr provides out of the box. You should be able to import this data via the `post` tool like we did for our `bibdata` core.

* `./server/solr/`: There is one folder here for each of the cores defined. For example, there should be a `bibdata` folder here with our core.

* `./server/solr-webapp/`: This is the code to power the "Dashboard" that we see when we visit http://localhost:8983/solr/#/
