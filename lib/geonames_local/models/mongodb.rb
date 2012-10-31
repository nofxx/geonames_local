require 'mongoid'
require 'mongoid_geospatial'

Mongoid.configure do |config|
  #config.master = Mongo::Connection.new.db("symbolize_test")
  config.connect_to(Opt[:db][:name])
end

module Geonames
  module Models


    class City < Geonames::Spot
      include Mongoid::Document
      include Mongoid::Geospatial
      store_in :collection => "cities"

      field :ascii, type: String
      field :slug,  type: String
      field :name,  type: String
      field :area
      field :gid,   type: Integer
      field :zip,   type: Integer
      field :geom,  type: Point, spatial: true

      belongs_to :province
      belongs_to :country, index: true
      # has_many :hoods

      before_validation :set_defaults

      validates :name, :country, presence: true
      validates :name, :uniqueness => { :scope => :province_id }

      index name: 1
      index slug: 1
      index geom: '2d'

      #spatial_index :geom

      scope :ordered, order_by(name: 1)

      def abbr
        abbr || province ? province.abbr : country.abbr
      end

      def set_defaults
        self.country ||= province.try(:country)
        self.slug    ||= name.try(:downcase) # don't use slugize
      end

      def self.search(search, page)
        cities = search ? where(:field => /#{search}/i) : all
        cities.page(page)
      end

      def <=> other
        self.name <=> other.name
      end

      def to_s
        "#{name}/#{province.abbr}"
      end

      def self.from_batch data
        data.each do |city|
          next unless city.country
          city = new.parse(city)
          city.country = city.province.country
          city.save!
        end
      end

      def parse(spot)
        self.name, self.ascii = spot.code, spot.name, spot.ascii
        self.code, self.gid = spot.code, spot.gid
        self.province = Province.find_by(code: spot.province)
        self
      end

    end


    class Province < Geonames::Spot
      include Mongoid::Document
      store_in :collection => "provinces"

      field :gid,    type: Integer  # geonames id
      field :code,   type: String
      field :name,   type: String
      field :abbr,   type: String
      field :codes,  type: Array # phone code

      belongs_to :country
      has_many :cities

      validates :name, presence: true
      validates :country, presence: true

      index name: 1
      index codes: 1

      scope :ordered, order_by(name: 1)

      def self.from_batch data
        data.each do |province|
          next unless province.country
          province = new.parse(province)
          province.country = Country.find_by(abbr: /#{province.country}/i)
          province.save!
        end
      end

      def parse(spot)
        self.code, self.name = spot.province, spot.name
        self.gid = spot.gid
        self
      end

    end


    class Country < Geonames::Spot
      include Mongoid::Document
      store_in :collection => "countries"

      field :gid,    type: Integer  # geonames id
      field :name,   type: String
      field :abbr,   type: String
      field :code    # optional phone/whatever code

      has_many :cities
      has_many :provinces

      validates :abbr, :name, presence: true, uniqueness: true

      index name: 1
      index code: 1

      scope :ordered, order_by(name: 1)


      def parse row
        self.abbr, @iso3, @ison, @fips, self.name, @capital, @area, @pop, continent, tld,
        currency, phone, postal, langs, gid, neighbours = row.split(/\t/)
        self
      end

      def self.from_batch data
        data.each do |spot|
          new.parse(spot).save
        end
      end

      def to_hash
        { "gid" => @gid.to_s, "name" => @name, "kind" => "country", "code" => @code}
      end

      def export
        [@gid, @code, @name]
      end

      def export_header
        ["gid", "code", "name"]
      end
    end



    class Zip
      include Mongoid::Document

      field :code
      belongs_to :city

    end

  end
end
