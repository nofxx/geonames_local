require 'mongoid_geospatial'
require 'geopolitical'
require 'geopolitical/../../app/models/concerns/geopolitocracy'
require 'geopolitical/../../app/models/nation'
require 'geopolitical/../../app/models/region'
require 'geopolitical/../../app/models/city'
require 'geopolitical/../../app/models/hood'

Mongoid.configure do |config|
  # config.master = Mongo::Connection.new.db("symbolize_test")
  info "Using Mongoid v#{Mongoid::VERSION}"
  info "Mongoid connecting to #{Opt[:db]}"
  config.connect_to(Opt[:db][:name])
end

module Geonames
  module Models
    module MongoWrapper
      class << self
        def batch(data)
          @regions, @cities = data[:region], data[:city]
          @regions.each { |r| create Region, parse_region(r) }
          @cities.each  { |c| create City, parse_city(c) }
        end

        def clean
          [Nation, Region, City].each(&:delete_all)
        end

        def create(klass, data)
          # info "#{klass}.new #{data}"
          klass.create! data
        rescue => e
          warn "Prob com spot #{e} #{e.backtrace.join("\n")}"
        end

        def translate(txt)
          name_i18n = Opt[:locales].reduce({}) do |h, l|
            h.merge(l => txt)
          end
        end

        #
        # Parse Nations
        #
        def nations(data)
          data.each do |row|
            create Nation, parse_nation(row) rescue nil
          end
        end

        def nations_populated?
          Nation.count > 0
        end

        def parse_nation(row)
          abbr, iso3, ison, fips, name, capital, area, pop, continent,
          tld, cur_code, cur_name, phone, pos_code, pos_regex,
          langs, gid, neighbours = row.split(/\t/)
          info "Nation: #{name}/#{abbr}"
          # info "#{row}"
          # info "------------------------"
          {
            name_translations: translate(name),
            postal: pos_code, cash: cur_code, gid: gid,
            abbr: abbr, slug: name.downcase, code: iso3, lang: langs
          }
        end

        #
        # Parse Regions
        #
        def parse_region(r)
          nation = Nation.find_by(abbr: /#{r.nation}/i)
          info "Region: #{r.name} / #{r.abbr}"
          {
            id: r.gid.to_s, abbr: r.abbr,
            name_translations: translate(r.name),
            nation: nation, code: r.region
          }
        end

        #
        # Parse Cities
        #
        def parse_city(s)
          region = Region.find_by(code: s.region)
          # ---
          # info s.inspect
          info "City: #{s.zip} | #{s.name} / #{region.try(:abbr)}"
          {
            id: s.gid.to_s, code: s.code,
            name_translations: translate(s.name),
            souls: s.pop, geom: [s.lon, s.lat],
            region_id: region.id.to_s, postal: s.zip # tz
          }
        end
      end
    end

    # class Nation < Geonames::Spot

    #   def parse row
    #   end

    #   def to_hash
    #     { "gid" => @gid.to_s, "name" => @name,
    #     "kind" => "nation", "code" => @code}
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
