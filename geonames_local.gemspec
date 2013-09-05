# -*- encoding: utf-8 -*-
require File.expand_path('../lib/geonames_local/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = %q{geonames_local}
  gem.version = Geonames::VERSION
  gem.homepage = %q{http://github.com/nofxx/geonames_local}

  gem.authors = ["Marcos Piccinini"]
  gem.default_executable = %q{geonames}
  gem.description = %q{Dumps geonames data to feed a local db}
  gem.email = %q{x@nofxx.com}
  gem.license = "MIT"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "geonames_local"
  gem.require_paths = ["lib"]
  gem.summary = %q{Dumps geonames data for local usage}

  gem.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.rdoc"
  ]

  gem.post_install_message = %q{
Geonames Local
--------------

To use the adapter, install the corresponding gem:

  PostgreSQL   =>   pg
  MongoDB      =>   mongoid (optional: mongo_ext)
  Tokyo        =>   tokyocabinet

Have fun because:
}
end
