require 'features/spot'
require 'features/country'
require 'features/city'
require 'features/road'
require 'features/zone'
require 'rubygems'
require 'logger'
require 'data/shp'
require 'data/tokyo'
require 'data/postgres'
require 'work/cli'
require 'work/dump'
require 'work/export'

module Geonames
  Opt = {}
  Cache = {:dump => [], :zip => [], :roads => [], :zones => []}
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__),'config', 'codes.yml')))
  VERSION =  File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
