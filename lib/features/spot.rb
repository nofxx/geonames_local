module Geonames
  class Spot
    attr_accessor :geoname_id, :name, :ascii, :lat, :lon, :country,
                  :code, :kind, :pop, :tz, :updated_at
    alias :x :lon
    alias :y :lat

    def initialize(params)
      parse(params)
    end

    def parse(row)
      gid, @name, @ascii, *tail = row.split(/\t/)
      @alternates = tail.delete_at(0) unless tail[0] =~ /\d|-/
      lat, lon, @code, kind, @country, cc2, adm1, adm2, adm3, adm4,
         pop, ele, gtop, @tz, @up = tail
      @lat = lat.to_f
      @lon = lon.to_f
      @geoname_id = gid.to_i
      @kind = human_code(kind)
    end

    def updated_at
      Time.utc(*@up.split("-"))
    end

    def to_hash
      { "gid" => @geoname_id, "name" => @name, "lat" => @lat, "lon" => @lon }
    end


    def human_code(code)
      case code
        when 'ADM1' then :province
        when 'ADM2' then :city
        else :other
      end
    end
  end
end
