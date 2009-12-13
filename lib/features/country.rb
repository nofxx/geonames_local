module Geonames
  class Country
    attr_accessor :code, :name

    def self.all
      # qry.addcond("kind", TBDQRY::QSTREQ, "country")
      # qry.map { |r| new(r) }
    end

    def self.parse(row)
      entry = row.split(/\t/)
      new({ :code => entry[0], :name => entry[4]})
    end

    def initialize(params)
      @code = params[:code]
      @name = params[:name]
    end

    def cities
      # qry.addcond("country", TBDQRY::QSTREQ, @code)
    end

    def to_hash
      { "name" => @name, "kind" => "country", "code" => @code}
    end

  end
end
