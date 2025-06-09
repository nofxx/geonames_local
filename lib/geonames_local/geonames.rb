module Geonames
  Opt = {}
  Cache = { dump: [], zip: [], roads: [], zones: [], alternate_names: {} } # Added :alternate_names
  Codes = YAML.load(File.read(File.join(File.dirname(__FILE__), 'config', 'codes.yml')))

  def self.info(txt) # Made into a class method
    return unless Opt[:verbose]
    puts(txt) # Logger.info...
  end

  def info(txt) # Instance method calls the class method
    Geonames.info(txt)
  end
end
