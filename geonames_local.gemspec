# -*- encoding: utf-8 -*-
require File.expand_path('../lib/geonames_local/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'geonames_local'
  gem.version = Geonames::VERSION
  gem.homepage = 'http://github.com/nofxx/geonames_local'

  gem.authors = ['Marcos Piccinini']
  gem.default_executable = 'geonames'
  gem.description = 'Dumps geonames data to feed a local db'
  gem.email = 'x@nofxx.com'
  gem.license = 'MIT'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'geonames_local'
  gem.require_paths = ['lib']
  gem.summary = 'Dumps geonames data for local usage'

  gem.extra_rdoc_files = [
    'MIT-LICENSE',
    'README.md'
  ]

  gem.add_dependency('mongoid', ['~> 3.1.0'])
  gem.add_dependency('geopolitical', ['> 0.8.1'])

  gem.post_install_message = '
Geonames Local
--------------

Use `geonames init` to create a config.yml file.
Or `geonames -c config.yml` to run using a config file.

Have fun!

'
end
