## Installing Solr with the Java Development Kit

### Prerequisites

To run Solr on our machine we need to have the Java Development Kit (JDK) installed. The version of Solr that we'll use in this tutorial requires a recent version of Java (Java 8 or greater). To verify if the JDK is installed run the following command from the Terminal:

```
$ java -version

  #
  # java version "11.0.2" 2019-01-15 LTS
  # Java(TM) SE Runtime Environment 18.9 (build 11.0.2+9-LTS)
  # Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11.0.2+9-LTS, mixed mode)
  #
```

If the JDK is installed on ouw machine we'll see the text indicating the version that we have (e.g. "11.0.2" above). If the version number is "11.x", "10.x", "9.x" or "1.8" we should be OK, otherwise, follow the steps below to install a recent version.

If we don't have the JDK installed we'll see something like

```
  #
  # -bash: java: command not found
  #
```

If a recent version of Java *is installed* on our machine skip the "Installing Java" section below and jump to the "Installing Solr" section. If Java *is not installed* on our machine or we have an old version follow the steps below to install a recent version.


### Installing Java

To install the Java Development Kit (JDK) go to http://www.oracle.com/technetwork/java/javase/downloads/index.html and click the "JDK Download" link.

From there, under the "Java SE Development Kit 13.0.2" select the file appropriated for our operating system. For Mac download the ".dmg" file (`jdk-13.0.2_osx-x64_bin.dmg`) and for Windows download the ".exe" file (`jdk-13.0.2_windows-x64_bin.exe`). Accept the license and download the file.

Run the installer that we downloaded and follow the instructions on screen. Once the installer has completed run the `java -version` command again. We should see the text with the Java version number this time.


### Installing Solr

Once Java has been installed on your machine to install Solr we just need to *download* a zip file, *unzip* it on our machine, and run it.

You can download Solr from the [Apache](https://solr.apache.org/) web site. To make it easy, below are the steps to download and install version 9.1.0 which is the one that we will be using.

First, download Solr and save it to a file on your machine:

```
$ cd
$ curl -OL http://archive.apache.org/dist/solr/solr/9.1.0/solr-9.1.0.tgz

  #
  # You'll see something like this...
  # % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                Dload  Upload   Total   Spent    Left  Speed
  # 100  146M  100  146M    0     0  7081k      0  0:00:21  0:00:21 --:--:-- 8597k
  #
```

Then unzip the downloaded file with the following command:

```
$ tar zxvf solr-9.1.0.tgz

  #
  # A ton of information will be displayed here as Solr is being
  # decompressed/unzipped. Most of the lines will say something like
  # "x solr-9.1.0/the-name-of-a-file"
  #
```

...and that's it, Solr is now available on your machine under the `solr-9.1.0` folder. Most of the utilities that we will use in this tutorial are under the `solr-9.1.0/bin` folder.

First, let's make sure we can run Solr by executing the `solr` shell script with the `status` parameter:

```
$ cd ~/solr-9.1.0/bin
$ ./solr status

  #
  # No Solr nodes are running.
  #
```

The "No Solr nodes are running" message is a bit anticlimactic but it's exactly what we want since it indicates that Solr is ready to be run.

**Note for Windows users:** In Windows use the `solr.cmd` batch file instead of the `solr` shell script, in other words, use `solr.cmd status` instead of `./solr status`.


### Let's get Solr started

To start Solr run the `solr` script again but with the `start` parameter:

```
$ ./solr start

  # [a couple of WARN messages plus...]
  #
  # Waiting up to 180 seconds to see Solr running on port 8983 [/]
  # Started Solr server on port 8983 (pid=31160). Happy searching!
  #
```

Notice that the message says that Solr is now running on port `8983`.

You can validate this by opening your browser and going to http://localhost:8983/. This will display the Solr Admin page from where you can perform administrative tasks as well as add, update, and query data from Solr.

You can also issue the `status` command again from the Terminal and Solr will report something like this:

```
$ ./solr status

  # Found 1 Solr nodes:
  #
  # Solr process 79276 running on port 8983
  # {
  #   "solr_home":"/Users/user-id/solr-9.1.0/server/solr",
  #   "version":"9.1.0 aa4f3d98ab19c201e7f3c74cd14c99174148616d - ishan - 2022-11-11 13:00:47",
  #   "startTime":"2023-01-17T00:36:52.104Z",
  #   "uptime":"0 days, 0 hours, 0 minutes, 40 seconds",
  #   "memory":"167 MB (%32.6) of 512 MB"}
  #
```

Notice how Solr now reports that it has "Found 1 Solr node". Yay!


## Creating our first Solr core

Solr uses the concept of *cores* to represent independent environments in which
we configure data schemas and store data. This is similar to the concept of a
"database" in MySQL or PostgreSQL.

For our purposes, let's create a core named `bibdata` as follows (notice these commands require that Solr be running, if you stopped it, make sure you run `solr start` first)

```
$ ./solr create -c bibdata

  # WARNING: Using _default configset with data driven schema functionality.
  # NOT RECOMMENDED for production use.
  #
  #           To turn off: bin/solr config -c bibdata -p 8983 -action set-user-property -property update.autoCreateFields -value false
  #
  # Created new core 'bibdata'
  #
```

Now we have a new core available to store documents. We'll ignore the warning because we are not in production, but we'll discuss this later on.

For now our core is empty (since we haven't added any thing to it) and you can check this with the following command from the terminal:

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*:*'

  #
  # {
  #  "responseHeader":{
  #    "status":0,
  #    "QTime":0,
  #    "params":{
  #      "q":"*:*"}},
  #  "response":{"numFound":0,"start":0,"docs":[]
  #  }}
  #
```

(or you can also point your browser to http://localhost:8983/solr#bibdata/query and click the "Execute Query" button at the bottom of the page)

in either case you'll see `"numFound":0` indicating that there are no documents on it.


## Adding documents to Solr

Now let's add a few documents to our `bibdata` core. First, [download this sample data](https://raw.githubusercontent.com/hectorcorrea/solr-for-newbies/main/books.json) file:

```
$ curl -OL https://raw.githubusercontent.com/hectorcorrea/solr-for-newbies/main/books.json

  #
  # You'll see something like this...
  #   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                  Dload  Upload   Total   Spent    Left  Speed
  # 100  1998  100  1998    0     0   5561      0 --:--:-- --:--:-- --:--:--  5581
  #
```

File `books.json` contains a small sample data a set with information about a
few thousand books. You can take a look at it via `cat books.json` or using the text editor of your choice. Below is an example on one of the books in this file:

```
{
  "id":"00008027",
  "author_txt_en":"Patent, Dorothy Hinshaw.",
  "authors_other_txts_en":["Muñoz, William,"],
  "title_txt_en":"Horses /",
  "responsibility_txt_en":"by Dorothy Hinshaw Patent ; photographs by William Muñoz.","publisher_place_str":"Minneapolis, Minn. :",
  "publisher_name_str":"Lerner Publications,",
  "publisher_date_str":"c2001.",
  "subjects_txts_en":["Horses","Horses"],
  "subjects_form_txts_en":["Juvenile literature"]
}
```

Then, import this file to our `bibdata` core with the `post` utility that Solr
provides out of the box (Windows users see note below):

```
$ ./post -c bibdata books.json

  #
  # (some text here...)
  # POSTing file books.json (application/json) to [base]/json/docs
  # 1 files indexed.
  # COMMITting Solr index changes to http://localhost:8983/solr/bibdata/update...
  # Time spent: 0:00:00.324
  #
```

Now if we run our query again we should see some results

```
$ curl 'http://localhost:8983/solr/bibdata/select?q=*:*'

  # Response would be something like...
  # {
  #   "responseHeader":{
  #     "status":0,
  #     "QTime":36,
  #     "params":{
  #       "q":"*:*"}},
  #   "response":{"numFound":30424,"start":0,"docs":[
  #       ... lots of information will display here ...
  #     ]}
  # }
  #
```

Notice how the number of documents found is greater than zero (e.g. `"numFound":30424`)

**Note for Windows users:** Unfortunately the `post` utility that comes out the box with Solr only works for Linux and Mac. However, there is another `post` utility buried under the `exampledocs` folder in Solr that we can use in Windows. Here is what you'll need to to:

```
> cd C:\Users\you\solr-9.1.0\examples\exampledocs
> curl -OL https://raw.githubusercontent.com/hectorcorrea/solr-for-newbies/main/books.json
> java -Dtype=application/json -Dc=bibdata -jar post.jar books.json

  #
  # you should see something along the lines of
  #
  # POSTing file books.json
  # 1 files indexed
  # COMMITting Solr index changes to http://...
  #
```
