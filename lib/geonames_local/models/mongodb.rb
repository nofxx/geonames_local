require 'mongoid'
require 'mongoid_geospatial'

I18n.locale = :en

Mongoid.configure do |config|
  #config.master = Mongo::Connection.new.db("symbolize_test")
  config.connect_to(Opt[:db][:name])
end

module Geonames
  module Models
    #module Mongodb
    require 'geopolitical/../../app/models/hood'
    require 'geopolitical/../../app/models/city'
    require 'geopolitical/../../app/models/region'
    require 'geopolitical/../../app/models/nation'

    module Nations
      def self.from_batch data
        # Nation.delete_all # if clean
        data.each do |row|
          # info row
         create! parse(row) rescue nil
        end
      end

      def self.create! data
        Nation.create! data
      rescue => e
        info "Prob com nation #{klass}, #{data} #{e}"
      end

      def self.parse row
        abbr, iso3, ison, fips, name, capital, area, pop, continent, tld,
        currency, phone, postal, langs, gid, neighbours = row.split(/\t/)
        info "Nation: #{name}/#{abbr}"
        {
          abbr: abbr, slug: name.downcase, name: name
        }
      end
    end

    module Spots
      class << self
        def from_batch data
          [Region, City].each(&:delete_all) # if clean

          @regions, @cities = data[:region], data[:city]
          @regions.each { |r| create Region, parse_region(r) }
          @cities.each  { |c| create City, parse_city(c) }
        end

        def create klass, data
          klass.create! data
        rescue => e
          info "Prob com spot #{klass}, #{data} #{e}"
        end

        def parse_region s
          nation = Nation.find_by(abbr: /#{s.nation}/i)
          info "Region: #{s.name} / #{s.abbr}"
          {
            gid: s.gid, name: s.name, abbr: s.abbr,
            nation: nation, code: s.region
          }
i        end

        def parse_city s
          region = Region.find_by(code: s.region)
          slug = "#{s.ascii}-#{region.abbr}"
          slug =  slug.downcase.gsub(/\W/, '').gsub(/\s/, '-')
          attempt = slug.dup
          try = 1
          until City.where(slug: attempt).first.nil?
            attempt = "#{slug}-#{try}"
            try += 1
            break if try > 7
          end
          slug = attempt
          # info s.inspect
          info "City: #{slug} - #{s.name} / #{region.try(:abbr)}"
          {
            name: s.name, slug: slug,
            code: s.code, gid: s.gid, ascii: s.ascii,
            region: region, souls: s.pop,
            geom: [s.lon, s.lat],
            abbr: region.abbr # tz
          }
        end

      end
    end

    # class City < Geonames::Spot
    #   # include Mongoid::Document
    #   # include Mongoid::Geospatial
    #   # store_in :collection => "cities"

    #   def self.from_batch data
    #     data.each do |city|
    #       info "Writing city #{city.name}"
    #       next unless city.nation
    #       city = ::Geopolitical::City.new(parse(city))
    #       city.save
    #     end
    #   end

    #   def parse s
    #
    #   end

    # end


    # class Region < Geonames::Spot

    #   def self.from_batch data

    #   end

    # end


    # class Nation < Geonames::Spot


    #   def parse row
    #   end

    #   def to_hash
    #     { "gid" => @gid.to_s, "name" => @name, "kind" => "nation", "code" => @code}
    #   end

    #   def export
    #     [@gid, @code, @name]
    #   end

    #   def export_header
    #     ["gid", "code", "name"]
    #   end
    # end



    # class Zip
    #   include Mongoid::Document

    #   field :code
    #   belongs_to :city

    # end

  end
end
