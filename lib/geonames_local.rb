#
# Geonames Extension
#
$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Require Libs
require 'geonames_local/geonames'

require 'geonames_local/adapters/mongodb'

module Geonames

  Adapter = Geonames::Mongodb.new

end

require 'geonames_local/models/mongo'
