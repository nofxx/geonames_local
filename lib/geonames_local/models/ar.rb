module Geonames
  module Models
    module AR

      class City < ActiveRecord::Base
        attr_accessor :x, :y, :z

        belongs_to :province
        belongs_to :country

        validates_presence_of :country
        validates_presence_of :name
        # validates_uniqueness_of :name, :scope => :province_id

        def abbr
          province.try(:abbr) || country.abbr
        end

        def geom=(val)
          self[:geom] = case val
          when Array then Point.xy(*val)
          else val
          end
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

        validates_uniqueness_of :name, :abbr,  :scope => :country_id
      end

      class Country < ActiveRecord::Base
        has_many :provinces
        has_many :cities
        validates_presence_of :name, :abbr
        validates_uniqueness_of :name, :abbr
      end

      class Spot < ActiveRecord::Base
        validates_presence_of :name
      end


    end
  end
end


