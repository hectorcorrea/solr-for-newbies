Notes for Solr for newbies workshop at Code4Lib 2018

## Outline

Introduction (`00_introduction.md`)
* What is Solr
* Solr's document model
* Inverted index
* What is Lucene

Installation (`10_installation.md`)
* Prerequisites / Installing Java
* Installing Solr
* Let's get Solr started
* Adding Solr to your path

Creating Cores (`11_creating_cores.md`)
* Creating our first Solr core

Adding documents (`12_adding_documents.md`)
* Adding documents to Solr

Searching - part I (`13_searching_intro.md`)
* Fetching data
* Selecting what fields to fetch
* Filtering the documents to fetch
* Getting facets

Deleting documents (`14_deleting_documents.md`)
* Deleting documents

Schema (`20_schema.md`)
* Field types, fields, dynamic fields, and copy fields
* Fields in our bibdata core
* Analyzers, Tokenizers, and Filters (`21_analyzers_tokenizers_filters.md`)  
* Stored vs indexed fields (`22_stored_indexed.md`)


Schema - part II
* Recreating our Solr core (`23_recreating_core.md`)
* Adding custom fields and reimporting our data (`24_adding_fields.md`)
* Dynamic Fields (`25_dynamic_fields.md`)

Searching - part II (`30_searching.md`)
* Query Parsers (standard, DisMax, eDisMax)
* Basic searching in Solr
* q and fq parameters
* debugQuery
* Ranking of documents
* Filtering with ranges

Searching - part III
* Facets (`31_facets.md`)
* Highlighting (`32_highlighting.md`)
* Advanced - phrase field (`33_search_advanced.md`)

Advanced
* Solr directories (`40_solr_directories.md`)
* Synonyms (`41_synonyms.md`)
* Configuration (`42_solrconfig_xml.md`)
* Spellcheck (`43_spellcheck.md`)
* Replication (`44_replication.md`)

References (`90_references.md`)
