#
# Geonames Local
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Require CLI Stuff
require 'geonames_local/geonames'
require 'geonames_local/cli'
require 'geonames_local/data/shp'
require 'geonames_local/data/dump'
require 'geonames_local/data/export'

