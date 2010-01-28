require "rubygems"
require "geo_ruby"

class Road
  attr_reader :city, :province, :country, :zone, :name, :geom, :kind, :table

  def initialize(keys, vals, country=nil, city=nil)
    s = vals.split("\t")
    r = {}
    keys.each_with_index do |k, i|
      r[k] = s[i]
    end
    @name = r[:name]
    @zone = r[:zone]
    kind  = r[:kind] || @name.split(" ")[0]
    @kind = parse_kind(kind)
    @city = city
    @country = country
    parse_geom(r[:geom])
    @table = :roads
  end

  def parse_geom(hex)
    @geom = GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(hex)
  end

  def geom=(g)
    @geom = g
  end

  def parse_kind(k)
    case k
      when /^tun/i then :tunnel
      when /^av/i then :avenue
      when /^r/i then :street
      when /\d/ then :road
      else :unknown
    end
  end

end
