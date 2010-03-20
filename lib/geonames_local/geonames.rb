require 'rubygems'
require 'logger'
require 'yaml'

require 'features/spot'
require 'features/country'
require 'features/city'
require 'features/road'
require 'features/zone'

module Geonames
  Opt = {}
  Cache = {:dump => [], :zip => [], :roads => [], :zones => []}
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', 'codes.yml')))
  VERSION =  File.read(File.join(File.dirname(__FILE__), '..', '..', 'VERSION'))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
