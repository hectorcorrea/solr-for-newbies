# PART IV - MISCELLANEOUS

## Solr directories

In the next sections we'll make a few changes to the configuration of our `bidata` core. Before we do that let's take a look at the files and directories that were created when we unzipped the `solr-7.1.0.zip` file.

Assuming we unzipped this zip file in our home directory we would have a folder `~/solr-7.1.0/` with several subdirectories underneath:     

* `bin/`: Scripts to start/stop Solr and post data to it.

* `dist/`: Contains the Java Archive (JAR) files. These are the binaries that make up Solr.

* `examples/`: Sample data that Solr provides out of the box. You should be able to import this data via the `post` tool like we did for our `bibdata` core.

* `server/solr/`: There is one folder here for each of the cores defined by default. For example, there should be a `bibdata` folder here for our core.

* `server/solr-webapp/`: This is the code to power the "Dashboard" that we see when we visit http://localhost:8983/solr/#/


### Your bibdata core

As noted above, our `bibdata` core is under the `server/solr/bibdata` folder. The structure of this folder is as follows:

```
~/solr-7.1.0/
|-- server/
    |-- solr/
        |-- bibdata/
            |-- conf/
            |-- data/
```

The `data` folder contains the data that Solr stores for this core. This is where the actual index is located. The only thing that you probably want to do with this folder is back it up regularly. Other than that, you should stay away from it :)  

The `conf` folder contains configuration files for this core. In the following sections we'll look at some of the files in this folder (e.g. `solrconfig.xml`, `stopwords.txt`, and `synonyms.txt`) and how they can be updated to configure different options in Solr.
