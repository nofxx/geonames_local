#
# Geonames Extension
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Require Libs
require 'geonames_local/features/spot'
require 'geonames_local/features/road'
require 'geonames_local/features/zone'

# Require Main
require 'geonames_local/geonames'
