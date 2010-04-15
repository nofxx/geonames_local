module Geonames
  module Model
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
  end
end
