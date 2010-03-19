require 'rubygems'
require 'logger'
require 'geonames_local/features/spot'
require 'geonames_local/features/country'
require 'geonames_local/features/city'
require 'geonames_local/cli'
require 'geonames_local/dump'
require 'geonames_local/export'

module Geonames
  Opt = {}
  VERSION =  File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
