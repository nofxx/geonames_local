require 'rubygems'
require 'logger'
require 'yaml'

require 'geonames_local/features/spot'
require 'geonames_local/features/road'
require 'geonames_local/features/zone'

module Geonames
  Opt = {}
  Cache = {:dump => [], :zip => [], :roads => [], :zones => []}
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', 'codes.yml')))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
