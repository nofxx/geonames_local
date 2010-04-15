$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'geonames_cli'
require 'spec'
require 'spec/autorun'
include Geonames

Spec::Runner.configure do |config|

end
