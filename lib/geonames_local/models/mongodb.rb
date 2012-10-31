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

      field :slug
      field :name
      field :area
      field :gid,   type: Integer
      field :zip,   type: Integer
      field :geom,  type: Point, spatial: true


      belongs_to :province
      belongs_to :country, index: true
      has_many :hoods

      before_validation :set_defaults

      validates :name, :country, presence: true
      validates_uniqueness_of :name, :scope => :province_id

      index name: 1
      index slug: 1
      index geom: '2d'

      #spatial_index :geom

      scope :ordered, order_by(name: 1)

      def abbr
        province ? province.abbr : country.abbr
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
        data.each do |params|
          c = new.parse(params)
          p c.name
          c.save
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

    class Province < Geonames::Spot
      include Mongoid::Document

      field :gid,    type: Integer  # geonames id
      field :name,   type: String
      field :abbr,   type: String
      field :codes,  type: Array # phone code

      belongs_to :country
      has_many :cities

      validates :name, presence: true

      index name: 1
      index codes: 1

      scope :ordered, order_by(name: 1)
      attr_accessor :code, :name, :gid

      def self.from_batch data
        data.each do |province|
          new.parse(province).save
        end
      end

      def parse(params)
        self.code = params["code"]
        self.name = params["name"]
        self.gid = params["gid"]
      end

    end

    class Zip
      include Mongoid::Document

      field :code
      belongs_to :city

    end

  end
end
