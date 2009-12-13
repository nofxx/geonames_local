require 'features/spot'
require 'features/country'
require 'features/city'
require 'rubygems'
require 'logger'
require 'data/tokyo'
require 'work/cli'
require 'work/dump'

module Geonames
  Opt = {}
  VERSION =  File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))

  def info(txt)
    if Opt[:verbose]
      puts(txt)
    end
  end
end
