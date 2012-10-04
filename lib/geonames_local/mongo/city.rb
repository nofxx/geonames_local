module Geonames
  # module Mongo
    class City < Geonames::Spot
      set_coll "cities"
    end
  # end
end
