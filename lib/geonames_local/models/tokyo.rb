module Geonames
  module Models
    module Tokyo

class Country
    attr_accessor :code, :name, :gid, :iso, :capital, :pop

    def self.all
      Tokyo.new.all({ :kind => "country" }).map do |c|
        new(c)
      end
    end

    # [0] iso alpha2
    # [1] iso alpha3
    # [2] iso numeric
    # [3] fips code
    # [4] name
    # [5] capital
    # [6] areaInSqKm
    # [7] population
    # [8] continent
    # [9] top level domain
    # [10] Currency code
    # [11] Currency name
    # [12] Phone
    # [13] Postal Code Format
    # [14] Postal Code Regex
    # [15] Languages
    # [16] Geoname id
    # [17] Neighbours
    # [18] Equivalent Fips Code
    #
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
