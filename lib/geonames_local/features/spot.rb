module Geonames
  #
  # Main Ruby Model for Geonames Spot Concept
  #
  class Spot
    attr_accessor :gid, :name, :ascii, :lat, :lon, :nation, :kind,
                  :code,  :pop, :tz, :geom, :region, :zip, :abbr, :id,
                  :feature_class, :feature_code # Added new attributes
    alias_method :x, :lon
    alias_method :y, :lat
    alias_method :geoname_id, :gid
    alias_method :table, :kind

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
        @name.gsub!(/Federal District/, 'Distrito Federal')
      end
    end

    #
    # Parse Geonames Dump Export
    #
    def parse(row)
      row = row.split(/\t/)
      info "[SPOT] #{row.join(' | ')}"
      # Assign to local variables first to preserve original feature_code
      gid_str, name_str, ascii_str, alternates_str, lat_str, lon_str, feat_class_str, feat_code_str,
      nation_str, _cc2, region_str, admin2_code_str, _adm3, _adm4, pop_str, _ele,
      _gtop, tz_str, up_str = row

      @name = name_str
      @ascii = ascii_str
      @alternates = alternates_str
      @lat = lat_str.to_f
      @lon = lon_str.to_f
      @feature_class = feat_class_str # Store raw feature class
      @feature_code = feat_code_str   # Store raw feature code
      @nation = nation_str
      @region = region_str # This is admin1 code
      @code = admin2_code_str # This is admin2 code, used for Spot's @code
      @pop = pop_str.to_i
      @tz = tz_str
      @up = up_str # For updated_at

      @gid = @geoname_id = gid_str.to_i
      @kind = human_code(@feature_code) # Determine :region, :city, :other based on original feature_code

      @abbr = @alternates.split(',').find { |n| n =~ /^[A-Z]{2,3}$/ } if @alternates

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
