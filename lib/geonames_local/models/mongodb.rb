module Geonames
  module Models
    module Mongo

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

    field :gid,    type: Integer  # geonames id
    field :name,   type: String
    field :abbr,   type: String
    field :code    # optional phone/whatever code

    has_many :cities
    has_many :provinces

    validates :abbr, :name, presence: true

    index name: 1
    index code: 1

    scope :ordered, order_by(name: 1)
        attr_accessor :code, :name, :gid, :iso, :capital, :pop
        set_coll "countries"

        def self.parse(row)
          new(row)
        end

        def initialize(params)
          parse(params)
        end

        def parse
          @iso, @iso3, @ison, @fips, @name, @capital, @area, @pop, continent, tld,
          currency, phone, postal, langs, gid, neighbours = row.split(/\t/)
          @code = iso
        end

        def cities
          # qry.addcond("country", TBDQRY::QSTREQ, @code)
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

        def self.from_batch

        end

        def initialize(params)
          @code = params["code"]
          @name = params["name"]
          @gid = params["gid"]
        end

      end
    end
  end
    class Zip
    include Mongoid::Document

    field :code
    belongs_to :city

  end
end
