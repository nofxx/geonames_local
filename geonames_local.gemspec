# -*- encoding: utf-8 -*-
require File.expand_path('../lib/geonames_local/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = %q{geonames_local}
  gem.version = Geonames::VERSION
  gem.homepage = %q{http://github.com/nofxx/geonames_local}

  gem.authors = ["Marcos Piccinini"]
  gem.default_executable = %q{geonames}
  gem.description = %q{Dump and feed a tokyo cabinet for local geonames search}
  gem.email = %q{x@nofxx.com}

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "mongoid_geospatial"
  gem.require_paths = ["lib"]
  gem.summary = %q{Dump and feed a tokyo local geonames db}


  gem.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]

  gem.add_dependency('georuby', ['>= 3.0.0'])

  gem.post_install_message = %q{
Geonames Local
--------------

To use the adapter, install the corresponding gem:

  PostgreSQL   =>   pg
  MongoDB      =>   mongodb (optional: mongo_ext)
  Tokyo        =>   tokyocabinet

PostgreSQL
----------

Be sure to use a database based on the PostGIS template.

MongoDB
-------

MongoDB 2D support is new, only mongo >= 1.3.3 mongodb gem >= 0.19.2
http://github.com/mongodb/mongo-ruby-driver

Have fun because:
}
end
