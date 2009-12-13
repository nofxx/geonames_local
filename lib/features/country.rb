  class Country
    attr_accessor :code, :name
    TBD_NAME = "countries"

    def self.all
      
    end

    def initializer(params)
      @code = params[:code]
      @name = params[:name]
    end

    def cities
      qry.addcond("country", TBDQRY::QSTREQ, @code)
    end

  end
