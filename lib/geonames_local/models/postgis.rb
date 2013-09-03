module Geonames
  module Models
    #module Postgis

      class City < ActiveRecord::Base
        attr_accessor :x, :y, :z

        belongs_to :region
        belongs_to :nation

        validates_presence_of :nation
        validates_presence_of :name
        # validates_uniqueness_of :name, :scope => :region_id

        def abbr
          region.try(:abbr) || nation.abbr
        end

        def geom=(val)
          self[:geom] = case val
          when Array then Point.xy(*val)
          else val
          end
        end

        # Instantiate self.geom as a Point
        def validation
          self.nation ||= region.nation
          unless !@x || !@y || @x == "" || @y == ""
            self.geom = Point.from_x_y(@x.to_f, @y.to_f)
          end
        end
      end

      class Region < ActiveRecord::Base
        has_many :cities
        belongs_to :nation

        validates_uniqueness_of :name, :abbr,  :scope => :nation_id
      end

      class Nation < ActiveRecord::Base
        has_many :regions
        has_many :cities
        validates_presence_of :name, :abbr
        validates_uniqueness_of :name, :abbr
      end

      class Spot < ActiveRecord::Base
        validates_presence_of :name
      end


    #end
  end
end
