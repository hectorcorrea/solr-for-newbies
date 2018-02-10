## Dynamic Fields

If look at the data in the source `books.json` file you'll notice that some of the records have a property named `urls_ss` that includes a list of URLs for the given book. For example the book with ID 17 has the following data:

```
{
  "id":"00000017",
  "author":"Tabb, John B.",
  "publisher":"Boston,",
  "urls_ss":["http://hdl.loc.gov/loc.gdc/scd0001.00162561418"],
  "subjects":["Children's poetry"]
}
```

You might be wondering what's the significance of the `_ss` in the URLs field. Why didn't we just name that property `urls`?

Solr supports the concept of something called "dynamic fields". Dynamic fields are fields that we define in Solr without giving them a full name, instead we indicate a pattern for the name of the field and Solr will automatically use that pattern for any field that we index that matches the pattern.

For example our `bibdata` core has already a set of dynamic fields defined. You can see them with the following command:

```
$ curl localhost:8983/solr/bibdata/schema/dynamicfields

  #
  # response will include one that looks like this
  #   {
  #     "name":"*_ss",
  #     "type":"strings",
  #     "indexed":true,
  #     "stored":true},
  #
```

notice that one of the definitions has the pattern `*_ss` which means any field that ends with `_ss` will be assigned the type `strings`, be indexed, and stored. You can dig further and figure out what the definition for the field type `strings` looks like with the following command:

```
$ curl localhost:8983/solr/bibdata/schema/fieldtypes/strings

  #
  # response will include
  # {
  #   "fieldType": {
  #     "name":"strings",
  #     "class":"solr.StrField",
  #     "sortMissingLast":true,
  #     "docValues":true,
  #     "multiValued":true
  #   }
  # }
```

What this means for us is that, when we imported the data from our JSON file, Solr automatically assigned the type `strings` to the `urls_ss` field because it matched the `*_ss` pattern.

There are lots of pre-defined dynamic fields in a standard Solr installation and you can also define your own dynamic fields.

Take a look at the dynamic fields defined in the `schema.xml` for these projects:

* Brown University Library Catalog (a Blacklight app): https://github.com/Brown-University-Library/bul-search/blob/master/solr_conf/blacklight-core/conf/schema.xml
* Penn State ScholarSphere (a Hydra/SamVera app): https://github.com/psu-stewardship/scholarsphere/blob/develop/solr/config/schema.xml
* Princeton University Library (a Blacklight app): https://github.com/pulibrary/pul_solr/blob/master/solr_configs/orangelight/conf/schema.xml

Notice the `*_tesim` vs `*_sim` dynamic field definitions in the Penn State configuration, the `*_sort` and `ignored_*` dynamic field definitions in Princeton's configuration, and the `*_display` vs `*_sort` definitions in Brown's configuration.
