module Geonames
  module Models
    module Mongo

      class City < Geonames::Spot
        set_coll "cities"
      end

      class Country < Geonames::Spot
        attr_accessor :code, :name, :gid, :iso, :capital, :pop
        set_coll "countries"

    def self.parse(row)
      new(row)
    end

    def initialize(params)
      parse(params)
    end

    def parse
      @iso, @iso3, @ison, @fips, @name, @capital, @area, @pop, continent, tld,
      currency, phone, postal, langs, gid, neighbours = row.split(/\t/)
      @code = iso
    end

    def cities
      # qry.addcond("country", TBDQRY::QSTREQ, @code)
    end

    def to_hash
      { "gid" => @gid.to_s, "name" => @name, "kind" => "country", "code" => @code}
    end

    def export
      [@gid, @code, @name]
    end

    def export_header
      ["gid", "code", "name"]
    end
  end

      class Province
    attr_accessor :code, :name, :gid

    def self.all
      Tokyo.new.all({ :kind => "province" }).map do |c|
        new(c)
      end
    end

    def initialize(params)
      @code = params["code"]
      @name = params["name"]
      @gid = params["gid"]
    end

  end
    end
  end
end
