# Adding documents to Solr

In the last section we ran a query against Solr that showed us that our
newly created core `bibdata` has no documents in it. Remember that our call to

```
$ curl "http://localhost:8983/solr/bibdata/select?q=*:*"
```

returned `"numFound":0`. Now let's add a few documents to this `bibdata` core. First, download this sample data file (if you cloned this GitHub repo the file is already in your data folder):

```
$ curl "https://raw.githubusercontent.com/hectorcorrea/solr-for-newbies/master/data/books.json" > books.json

  #
  # You'll see something like this...
  #   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  #                                  Dload  Upload   Total   Spent    Left  Speed
  # 100  1998  100  1998    0     0   5561      0 --:--:-- --:--:-- --:--:--  5581
  #
```

File `books.json` contains a small sample data a set with information about a
few thousand books. Go ahead and take a look at it (e.g. via `cat books.json`)

Then, import this file to our `bibdata` core with the `post` utility that Solr
provides out of the box:

```
$ ~/solr-7.1.0/bin/post -c bibdata books.json

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
$ curl "http://localhost:8983/solr/bibdata/select?q=*:*"

  # Response would be something like...
  # {
  #   "responseHeader":{
  #     "status":0,
  #     "QTime":36,
  #     "params":{
  #       "q":"*:*"}},
  #   "response":{"numFound":1000,"start":0,"docs":[
  #       ... lots of information will display here ...
  #     ]}
  # }
  #
```

Notice how the number of documents found is greater than zero (e.g. `"numFound":1000`)
