require 'mongoid'
require 'mongoid_geospatial'


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

    module Nations
      def self.from_batch data
        Nation.delete_all # if clean
        data.each do |row|
          # info row
          create! parse(row) rescue nil
        end
      end

      def self.create! data
        n = Nation.create! data
        info n.inspect
      rescue => e
        info "Prob com nation #{klass}, #{data} #{e}"
      end

      def self.parse row
        abbr, iso3, ison, fips, name, capital, area, pop, continent,
        tld, cur_code, cur_name, phone, pos_code, pos_regex,
        langs, gid, neighbours = row.split(/\t/)
        info "Nation: #{name}/#{abbr}"
        info "#{row}"
        info "------------------------"


        name_i18n = Opt[:locales].reduce({}) do |h, l|
          h.merge({ l => name })
        end

        {
          name_translations: name_i18n, zip: pos_code, cash: cur_code,
          abbr: abbr, slug: name.downcase, code: iso3, lang: langs
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
        end

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
