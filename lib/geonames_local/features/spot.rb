module Geonames
  class Spot
    attr_accessor :gid, :name, :ascii, :lat, :lon, :country, :kind,
                  :code,  :pop, :tz, :geom, :province, :zip, :abbr
    alias :x :lon
    alias :y :lat
    alias :geoname_id :gid
    alias :table :kind

    #
    # = Geonames Spot
    #
    # Every geoname type will be parsed as a spot
    def initialize(params, k)
      return unless params.instance_of? String
      k == :zip ? parse_zip(params) :  parse(params)
      if @kind == :provinces
        @name.gsub!(/Estado d\w\s/, "")
        @abbr = get_abbr
      end
    end

    # Geonames donest have province/state abbr..#fail!
    # This works 75% of the time in brazil heh
    def get_abbr
      s = @name.split(" ")
      if s.length > 1
        [s[0][0].chr,s[-1][0].chr].map(&:upcase).join
      else
        s[0][0..1].upcase
      end
    end

    #
    # Parse Geonames Dump Export
    def parse(row)
      gid, @name, @ascii, @alternates, lat, lon, feat, kind,
        @country, cc2, adm1, adm2, adm3, adm4, pop, ele,
        gtop, @tz, @up = row.split(/\t/)

      parse_geom(lat, lon)
      @gid = @geoname_id = gid.to_i
      @kind = human_code(kind)
      @province = adm1
      @code = adm2
    end

    #
    # Parse Geonames Zip Export
    def parse_zip(row)
      country, zip, @name, province, cc, dunno, adm1, adm2, lat, lon  = row.split(/\t/)
      parse_geom(lat, lon)
      @code = adm1
      @kind = :cities
      @zip = zip.split("-")[0]
    end

    #
    # Parse Geom to float or GeoRuby Point
    def parse_geom(lat, lon)
      @lat, @lon = lat.to_f, lon.to_f

      if defined?("GeoRuby")
        @geom = GeoRuby::SimpleFeatures::Point.from_x_y(@lon, @lat)
      end
    end

    #
    # Parse Time
    def updated_at
      Time.utc(*@up.split("-"))
    end

    # For tokyo
    def to_hash
      { "id" => @geoname_id, "gid" => @geoname_id.to_s, "kind" => @kind.to_s,
        "name" => @name, "ascii" => @ascii, "country" => @country,
        "geom" => {"y" => @lat.to_s, "x" => @lon.to_s}, "tz" => @tz }
    end


    def human_code(code)
      case code
        when 'ADM1' then :provinces
        when 'ADM2' then :cities
        else :other
      end
    end
  end
end
