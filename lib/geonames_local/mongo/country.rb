module Geonames
  class Country
    attr_accessor :code, :name, :gid, :iso, :capital, :pop, :currency

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

    def parse(row)
      @iso, @iso3, @ison, @fips, @name, @capital, @area, @pop, @continent, @tld,
      @currency, @currency_name, @phone, @postal_format, @postal_regex, @langs, @gid, @neighbours = row.split(/\t/)
      @code = iso
    end

    def cities
      # qry.addcond("country", TBDQRY::QSTREQ, @code)
    end

    def to_hash
      # { "gid" => @gid.to_s, "name" => @name, "kind" => "country", "code" => @code, "currency" => @currency}
	  { "gid" => @gid.to_s, "iso" => @iso, "iso3" => @iso3, "iso_num" => @ison, "fips" => @fips,
		"name" => @name, "capital" => @capital, "area" => @area, "population" => @pop,
		"continent" => @continent, "tld" => @tld, "currency_code" => @currency, "currency_name" => @currency_name,
		"phone" => @phone, "postal_code_format" => @postal_format, "postal_code_regex" => @postal_regex,
		"languages" => @langs, "neighbours" => @neighbours }
    end

    def export
      [@gid, @code, @name]
    end

    def export_header
      ["gid", "code", "name"]
    end
  end
end
