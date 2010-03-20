#
# Geonames Extension
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Require Libs
require 'geonames_local/geonames'
require 'geonames_local/model/country'
require 'geonames_local/model/province'
require 'geonames_local/model/city'
#require 'geonames_local/data/shp'

