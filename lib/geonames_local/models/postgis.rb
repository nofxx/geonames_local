module Geonames
  module Models
    # module Postgis

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
        unless !@x || !@y || @x == '' || @y == ''
          self.geom = Point.from_x_y(@x.to_f, @y.to_f)
        end
      end
    end

    class Region < ActiveRecord::Base
      has_many :cities
      belongs_to :nation

      validates_uniqueness_of :name, :abbr,  scope: :nation_id
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

    # end
  end
end

#   === Migration

# Default PG migration:

#     create_table :cities do |t|
#       t.references :country, :null => false
#       t.references :province
#       t.string  :name,   :null => false
#       t.point   :geom,   :srid => 4326
#       t.integer :gid, :zip
#     end

#     create_table :provinces do |t|
#       t.references :country, :null => false
#       t.string :name, :null => false
#       t.string :abbr, :limit => 2, :null => false
#       t.integer :gid
#     end

#     create_table :countries do |t|
#       t.string :name, :limit => 30, :null => false
#       t.string :abbr, :limit => 2,  :null => false
#     end

#     add_index :cities, :name
#     add_index :cities, :zip
#     add_index :cities, :country_id
#     add_index :cities, :province_id
#     add_index :cities, :gid,  :unique  => true
#     add_index :cities, :geom, :spatial => true
#     add_index :provinces, :name
#     add_index :provinces, :abbr
#     add_index :provinces, :country_id
#     add_index :provinces, :gid,  :unique => true
#     add_index :countries, :abbr, :unique => true
#     add_index :countries, :name, :unique => true
