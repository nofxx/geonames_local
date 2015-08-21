Geonames Local
==============

Downloads and store Geonames.org data locally (MongoDB, Mongoid).
Making every Geoname API operation possible on your servers.
**No hit limit, fast as possible.**


* Download all country data
* Merges ZIP into cities, so you have masks
* Updates using geonames IDs, no duplication


Use
---

Install where you want to populate the DB:

    gem install geonames_local


You will also need in your system:

* unzip
* curl


Config
------

Create a config yml file:

    geonames init

Will generate a `geonames.yml` file on your folder.
The file is self explanatory.

Geonames *splits the nations/countries database* from the rest, so:
It'll also populate the nations collection automatically: `252` nations.


    geonames -c geonames.yml

To run it. Use `-v` for verbose.


If you are not sure your country/nation code, use:

    geonames list <search>


Mongoid
-------

Using **http://github.com/fireho/geopolitical** models:


  City.first.region.nation.abbr
  => "BR"



Next
----

- IP Geonames? http://ipinfodb.com
- Hoods? ftp://geoftp.ibge.gov.br/malhas_digitais/censo_2010/setores_censitarios/
- ActiveRecord/PostGIS - someone else
