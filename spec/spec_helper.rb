$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_cli'
require 'rspec'
require 'rspec/autorun'
include Geonames

RSpec.configure do |config|

end
