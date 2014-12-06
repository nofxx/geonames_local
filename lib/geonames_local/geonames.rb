module Geonames
  Opt = {}
  Cache = { dump: [], zip: [], roads: [], zones: [] }
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', 'codes.yml')))

  def info(txt)
    return unless Opt[:verbose]
    puts(txt) # Logger.info...
  end
end
