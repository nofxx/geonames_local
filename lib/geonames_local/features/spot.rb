module Geonames
  #
  # Main Ruby Model for Geonames Spot Concept
  #
  class Spot
    attr_accessor :gid, :name, :ascii, :lat, :lon, :nation, :kind,
                  :code,  :pop, :tz, :geom, :region, :zip, :abbr, :id
    alias :x :lon
    alias :y :lat
    alias :geoname_id :gid
    alias :table :kind

    #
    # = Geonames Spot
    #
    # Every geoname type will be parsed as a spot
    #
    def initialize(params = nil, kind = nil)
      return unless params.instance_of? String
      kind == :zip ? parse_zip(params) : parse(params)
      if @kind == :region
        @name.gsub!(/Estado d\w\s/, '')
        @abbr = get_abbr
      end
    end

    #
    # Geonames does not have region/state abbr..#fail!
    # This works 75% of the time in brazil heh
    #
    def get_abbr
      s = @name.split(' ')
      if s.length > 1
        [s[0][0].chr, s[-1][0].chr].map(&:upcase).join
      else
        s[0][0..1].upcase
      end
    end

    #
    # Parse Geonames Dump Export
    #
    def parse(row)
      gid, @name, @ascii, @alternates, lat, lon, feat, kind,
      @nation, _cc2, @region, @code, _adm3, _adm4, @pop, @ele,
      @gtop, @tz, @up = row.split(/\t/)

      @gid = @geoname_id = gid.to_i
      @kind = human_code(kind)

      parse_geom(lat, lon)
      # puts "#{@kind} - #{@code} - #{@region}"
    end

    #
    # Parse Geonames Zip Export
    #
    def parse_zip(row)
      _nation, @zip, @name, _a1, _a1c, _a2, @code, _a3, _a3c,
      lat, lon, _acc = row.split(/\t/)

      @kind = :city
      parse_geom(lat, lon)
      # puts "#{row}\n---\n#{@kind} - #{@code} - #{@zip} #{lat}x#{lon}"
    end

    #
    # Parse Geom to float or GeoRuby Point
    #
    def parse_geom(lat, lon)
      @lat, @lon = lat.to_f, lon.to_f

      if defined? GeoRuby
        @geom = GeoRuby::SimpleFeatures::Point.from_x_y(@lon, @lat)
      else
        { lat: @lat, lon: @lon }
      end
    end

    def alt
      @ele || @gtop
    end

    #
    # Parse Time
    def updated_at
      Time.utc(*@up.split('-'))
    end

    # Translate geonames ADMx to models
    def human_code(code)
      case code
      when 'ADM1' then :region
      when 'ADM2', 'ADM3', 'ADM4' then :city
      else :other
      end
    end

    class << self

      attr_accessor :collection

      def nearest(x, y)
        from_hash(Adapter.find_near(collection, x, y, 1)[0])
      end

      def from_hash(hsh)
        spot = new
        hsh.each { |key, val| spot.instance_variable_set("@#{key}", val) }
        spot.geom = GeoRuby::SimpleFeatures::Point.from_x_y(*spot.geom)
        spot
      end

    end

  end

end
