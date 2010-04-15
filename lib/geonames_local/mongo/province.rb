module Geonames
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
