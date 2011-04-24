#
# Geonames Extension
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Adapter = Geonames::Postgres.new(Opt[:db])
# Require Libs
require 'geonames_local/geonames'

require 'geonames_local/models/ar'
#require 'geonames_local/data/shp'
