$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'logger'
require 'yaml'
require 'geonames_local/features/spot'
require 'geonames_local/features/country'
require 'geonames_local/features/city'
require 'geonames_local/features/road'
require 'geonames_local/features/zone'
require 'geonames_local/data/shp'
require 'geonames_local/cli'
require 'geonames_local/dump'
require 'geonames_local/export'

module Geonames
  Opt = {}
  Cache = {:dump => [], :zip => [], :roads => [], :zones => []}
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__), 'geonames_local', 'config', 'codes.yml')))
  VERSION =  File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
