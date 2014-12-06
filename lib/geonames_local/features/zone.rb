#
# A polygon basically.
#
class Zone
  attr_reader :city, :name, :geom, :kind

  def initialize(keys, vals, city = nil)
    s = vals.split("\t")
    r = {}
    keys.each_with_index do |k, i|
      r[k] = s[i]
    end
    @name = r[:name]
    @zone = r[:zone]
    @kind = :zone # @name.split(" ")[0] unless kind
    @city = city
    parse_geom(r[:geom])
  end

  def parse_geom(hex)
    @geom = GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(hex)
  end
end
