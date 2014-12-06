require 'rubygems'
require 'geo_ruby'

class Road
  attr_reader :city, :region, :nation, :zone, :name, :geom, :kind, :table

  def initialize(keys, vals, nation = nil, city = nil)
    s = vals.split("\t")
    r = {}
    keys.each_with_index do |k, i|
      r[k] = s[i]
    end
    @name = r[:name]
    @zone = r[:zone]
    kind  = r[:kind] || @name.split(' ')[0]
    @geom = parse_geom(r[:geom])
    @kind = parse_kind(kind)
    @city = city
    @nation = nation
    @table = :roads
  end

  def parse_geom(hex)
    if hex =~ /^SRID/ # PG 8.3 support
      hex = hex.split(';')[1]
    end
    GeoRuby::SimpleFeatures::Geometry.from_hex_ewkb(hex)
  end

  attr_writer :geom

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
