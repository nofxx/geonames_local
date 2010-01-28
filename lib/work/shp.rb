module Geonames
  class SHP
    Spots = []

    def sqp2pg
      `sph2pgsql -D -as 4326 #{file} nil > #{file}.dump`
    end

    def parse
      Spots << Street.new(row)
    end


  end
end
