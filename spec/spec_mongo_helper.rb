$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_local'
require 'rspec'
require 'rspec/autorun'
include Geonames::Models::Mongo
