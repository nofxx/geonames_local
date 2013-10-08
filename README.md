Geonames Local
==============

Downloads and store Geonames.org data locally (MongoDB, Mongoid).
Making every Geoname API operation possible on your servers.
No hit limit, fast as possible.


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


Will generate a "geonames.yml" file on your folder.
The file is self explanatory.

  geonames -c geonames.yml

To run it. Use -v for verbose.

If you are not sure your country/nation code, use:

  geonames list <search>

To populate the nations database for the first time use:

  geonames -c geoconfig.yml nations


Adapters
--------

So, supposing Mongoid, something like this is possible:

  City.first.province.country.abbr
  => "BR"


== Postgis

TBD (by someone else)
Be sure to use a database based on the PostGIS template.




Next
----

- IP Geonames? http://ipinfodb.com
