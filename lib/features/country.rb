module Geonames
  class Country
    attr_accessor :code, :name, :gid

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
      entry = row.split(/\t/)
      new({ "code" => entry[0], "name" => entry[4], "gid" => entry[16]})
    end

    def initialize(params)
      @code = params["code"]
      @name = params["name"]
      @gid = params["gid"]
    end

    def cities
      # qry.addcond("country", TBDQRY::QSTREQ, @code)
    end

    def to_hash
      { "gid" => @gid.to_s, "name" => @name, "kind" => "country", "code" => @code}
    end

  end
end
