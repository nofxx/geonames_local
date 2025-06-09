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

  db_settings = Opt[:db]
  puts db_settings.inspect #if Opt[:debug]
  unless db_settings.is_a?(Hash)
    msg = "FATAL: Opt[:db] is not configured correctly in your geonames.yml"
    STDERR.puts msg
    info msg # also log it if logger is configured
    raise ArgumentError, "Opt[:db] configuration error: #{msg}"
  end

  # Critical validation for host and database name from db_settings
  unless db_settings[:host].is_a?(String) && !db_settings[:host].empty?
    msg = "FATAL: MongoDB host (db_settings[:host]) is not a valid non-empty string. Value: #{db_settings[:host].inspect}"
    STDERR.puts msg
    info msg # Log it if logger is configured
    raise ArgumentError, msg
  end

  unless db_settings[:name].is_a?(String) && !db_settings[:name].empty?
    msg = "FATAL: MongoDB database name (db_settings[:name]) is not a valid non-empty string. Value: #{db_settings[:name].inspect}"
    STDERR.puts msg
    info msg # Log it if logger is configured
    raise ArgumentError, msg
  end

  # Configure the default client in the modern Mongoid way (Mongoid 4.0+)
  client_config_options = {}
  if db_settings[:options].is_a?(Hash)
    client_config_options.merge!(db_settings[:options])
  end
  # Example: allow SSL to be configured via geonames.yml :db section if needed in the future
  # client_config_options[:ssl] = db_settings[:ssl] if db_settings.key?(:ssl)

  default_client_config = {
    hosts: [db_settings[:host]],    # From geonames.yml, e.g., ["localhost:28017"]
    database: db_settings[:name],  # From geonames.yml, e.g., "geonames_local"
    options: client_config_options # Pass merged options here
  }

  # Add authentication details to the client configuration if provided in db_settings
  if db_settings[:username]
    default_client_config[:username] = db_settings[:username]
  end
  if db_settings[:password]
    default_client_config[:password] = db_settings[:password]
  end

  config.clients.default = default_client_config

  # Log the effective configuration for the default client.
  # Create a sanitized version for logging to avoid exposing passwords in logs.
  effective_config_log = default_client_config.dup
  if effective_config_log.key?(:password) && effective_config_log[:password]
    effective_config_log[:password] = '********'
  end
  info "Mongoid default client configured with: #{effective_config_log.inspect}"

  # The config.connect_to call is generally not needed when setting config.clients.default
  # directly, as the database name is part of the client's configuration.
  # Mongoid will use the 'default' client by default.
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
          dup = klass.find(data[:id])
          dup.assign_attributes(data)
          warn "[DUP CHANGES]...#{dup.changes}..."
        rescue Mongoid::Errors::DocumentNotFound
          klass.create! data
        rescue => e
          warn "[SPOT ERR] #{e} #{e.backtrace.reverse.join("\n")}"
          warn "[SPOT #{klass}] #{data}"
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
          Nation.count > 10
        end

        def parse_nation(row)
          abbr, iso3, ison, fips, name, capital, area, pop, continent,
          tld, cur_code, cur_name, phone, pos_code, pos_regex,
          langs, gid, neighbours = row.split(/\t/)
          info "[GEO NATION] #{name}/#{abbr}"
          # info "#{row}"
          # info "------------------------"
          {
            id: abbr,
            name_translations: translate(name),
            postal: pos_code,
            cash: cur_code,
            gid: gid,
            pop: pop.to_i,
            abbr: abbr,
            slug: name.downcase,
            code: iso3,
            lang: langs
          }
        end

        #
        # Parse Regions
        #
        def parse_region(r)
          nation = Nation.find_by(abbr: /#{r.nation}/i)
          info "[GEO REGION] #{r.gid} | #{r.inspect}"
          {
            id: r.gid.to_s,
            abbr: r.abbr,
            pop: r.pop.to_i,
            name_translations: translate(r.name),
            nation: nation,
            code: r.region
          }
        end

        #
        # Parse Cities
        #
        def parse_city(s)
          region = Region.find_by(code: s.region, nation: s.nation)
          # ---
          # info s.inspect
          info "[GEO CITY] #{s.gid} | #{s.name} / #{region} / #{s.nation}"
          info s.inspect
          {
            id: s.gid.to_s,
            code: s.code,
            name_translations: translate(s.name),
            pop: s.pop,
            geom: [s.lon, s.lat],
            region_id: region.id.to_s,
            postal: s.zip # tz
          }
        end
      end
    end
  end
end
