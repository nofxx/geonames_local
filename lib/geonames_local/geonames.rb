require 'logger'
require 'yaml'

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
