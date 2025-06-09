# -*- encoding: utf-8 -*-
require File.expand_path('../lib/geonames_local/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'geonames_local'
  s.version = Geonames::VERSION
  s.homepage = 'http://github.com/nofxx/geonames_local'

  s.authors = ['Marcos Piccinini']
  s.description = 'Dumps geonames data to feed a local db'
  s.email = 'x@nofxx.com'
  s.license = 'MIT'

  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.name          = 'geonames_local'
  s.require_paths = ['lib']
  s.summary = 'Dumps geonames data for local usage'

  s.extra_rdoc_files = [
    'MIT-LICENSE',
    'README.md'
  ]

  s.add_development_dependency('mongoid', ['>= 4.0.0'])

  s.post_install_message = '
Geonames Local
--------------

Use `geonames init` to create a config.yml file.
Or `geonames -c config.yml` to run using a config file.

Have fun!

'
end
