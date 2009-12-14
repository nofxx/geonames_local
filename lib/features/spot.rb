module Geonames
  class Spot
    attr_accessor :geoname_id, :name, :ascii, :lat, :lon, :country,
                  :code, :kind, :pop, :tz
    alias :x :lon
    alias :y :lat
    alias :gid :geoname_id

    def initialize(params)
      parse(params) if params.instance_of? String
    end

    def parse(row)
      gid, @name, @ascii, *tail = row.split(/\t/)
      @alternates = tail.delete_at(0) unless tail[0] =~ /\d|-/
      lat, lon, @code, kind, @country, cc2, adm1, adm2, adm3, adm4,
         pop, ele, gtop, @tz, @up = tail
      @lat, @lon =  lat.to_f, lon.to_f
      @geoname_id = gid.to_i
      @kind = human_code(kind)
    end

    def updated_at
      Time.utc(*@up.split("-"))
    end

    def to_hash
      { "gid" => @geoname_id.to_s, "kind" => @kind.to_s, "name" => @name, "ascii" => @ascii,
        "lat" => @lat.to_s, "lon" => @lon.to_s, "tz" => @tz, "country" => @country }
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
