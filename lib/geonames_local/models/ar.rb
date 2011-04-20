module Geonames
  module Models
    module AR

      class City < ActiveRecord::Base
        attr_accessor :x, :y, :z

        belongs_to :province
        belongs_to :country

        validates_presence_of :country
        validates_presence_of :name

        def abbr
          province.try(:abbr) || country.abbr
        end

        # Instantiate self.geom as a Point
        def validation
          self.country ||= province.country
          unless !@x || !@y || @x == "" || @y == ""
            self.geom = Point.from_x_y(@x.to_f, @y.to_f)
          end
        end

      end

      class Province < ActiveRecord::Base
        has_many :cities
        belongs_to :country
      end

      class Country< ActiveRecord::Base
        attr_accessor :code, :name, :gid, :iso, :capital, :pop
        has_many :provinces
        has_many :cities
      end

    end
  end
end


