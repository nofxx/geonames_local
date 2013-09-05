require 'mongoid'
require 'mongoid_geospatial'
require 'geopolitical/helpers'

Mongoid.configure do |config|
  #config.master = Mongo::Connection.new.db("symbolize_test")
  config.connect_to(Opt[:db][:name])
end

module Geonames
  module Models
    require 'geopolitical/../../app/models/hood'
    require 'geopolitical/../../app/models/city'
    require 'geopolitical/../../app/models/region'
    require 'geopolitical/../../app/models/nation'
    module MongoWrapper

      class << self

        def nations data, clean
          Nation.delete_all if clean
          data.each do |row|
            create Nation, parse_nation(row) rescue nil
          end
        end


        def batch data, clean = false
          [Region, City].each(&:delete_all) if clean

          @regions, @cities = data[:region], data[:city]
          @regions.each { |r| create Region, parse_region(r) }
          @cities.each  { |c| create City, parse_city(c) }
        end

        def create klass, data
          klass.create! data
        rescue => e
          info "Prob com spot #{klass}, #{data} #{e}"
        end

        def translate txt
          name_i18n = Opt[:locales].reduce({}) do |h, l|
            h.merge({ l => txt })
          end
        end


        def parse_nation row
          abbr, iso3, ison, fips, name, capital, area, pop, continent,
          tld, cur_code, cur_name, phone, pos_code, pos_regex,
          langs, gid, neighbours = row.split(/\t/)
          info "Nation: #{name}/#{abbr}"
          # info "#{row}"
          # info "------------------------"
          {
            name_translations: translate(name),
            zip: pos_code, cash: cur_code, gid: gid,
            abbr: abbr, slug: name.downcase, code: iso3, lang: langs
          }
        end


        def parse_region s
          nation = Nation.find_by(abbr: /#{s.nation}/i)
          info "Region: #{s.name} / #{s.abbr}"
          {
            name_translations: translate(s.name),
            gid: s.gid, abbr: s.abbr,
            nation: nation, code: s.region
          }
        end

        def parse_city s
          region = Region.find_by(code: s.region)
          slug = City.new(slug: s.ascii).slug
          attempt = slug.dup
          try = 1
          until City.where(slug: attempt.downcase).first.nil?
            attempt = "#{slug}-#{region.abbr}-#{try}"
            try += 1
            break if try > 7
          end
          # ---
          # info s.inspect
          info "City: #{s.zip} | #{slug} - #{s.name} / #{region.try(:abbr)}"
          {
            name_translations: translate(s.name),
            slug: attempt, gid: s.gid, code: s.code,
            souls: s.pop, geom: [s.lon, s.lat],
            region: region, abbr: region.abbr, zip: s.zip # tz
          }
        end

      end
    end


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
