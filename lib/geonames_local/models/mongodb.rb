require 'mongoid_geospatial'
require 'geopolitical'
require 'geopolitical/../../app/models/concerns/geopolitocracy'
require 'geopolitical/../../app/models/nation'
require 'geopolitical/../../app/models/region'
require 'geopolitical/../../app/models/city'
require 'geopolitical/../../app/models/hood'
require_relative '../regions/abbr' # Added to access the new Abbr module
require 'active_support/inflector' # For ActiveSupport::Inflector.parameterize

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
          @cities.each do |c|
            city_pop = c.pop.to_i
            # Opt[:min_pop] is read from geonames.yml, default to 0 if not found or not an integer
            min_pop_threshold = Opt[:min_pop].to_i

            if city_pop >= min_pop_threshold
              create City, parse_city(c)
            else
              info "[GEO CITY SKIP] #{c.inspect} (Pop: #{city_pop}) does not meet min_pop: #{min_pop_threshold}"
            end
          end
        end

        def clean
          [Nation, Region, City, Hood].each(&:delete_all)
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
          info "[NATION] #{name}/#{abbr}"
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
          info "[REGION] #{r.gid} | #{r.inspect}"
          region_abbr = Geonames::Regions::Abbr.get_abbr(r.name, r.nation)
          info "[REGION ABBR] For '#{r.name}' in '#{r.nation}', found abbr: '#{region_abbr}'"

          parsed_data = {
            id: r.gid.to_s,
            # The r.abbr might be from the input data source,
            # we prioritize our new logic via region_abbr.
            # If the Region model itself has an 'abbr' field, this will set it.
            abbr: region_abbr,
            pop: r.pop.to_i,
            name_translations: translate(r.name),
            nation: nation,
            code: r.region # This is often the admin1_code
          }
          # If r.abbr exists from source and our logic didn't find one, consider using it or logging.
          # For now, our logic takes precedence. If region_abbr is nil, :abbr will be nil.
          # If the original r.abbr was different, it gets overwritten.
          # If the Region model expects a field named 'original_abbr' or similar, that could be added.
          parsed_data
        end

        #
        # Parse Cities
        #
        def parse_city(s)
          # s.nation is country_code (e.g., 'US', 'BR')
          # s.region is admin1_code (e.g., 'CA', 'SP')
          # We need to find the Region object using its code and the nation object (or nation's abbr)
          nation_obj = Nation.find_by(abbr: /#{s.nation}/i)
          region = nil
          if nation_obj
            # Assuming Region.code stores the admin1_code like 'CA', 'SP'
            # And Region.nation stores the Nation object
            region = Region.find_by(code: s.region, nation_id: nation_obj.id)
          end

          info "[CITY] #{s.gid} | #{s.name} / #{region&.abbr} #{region&.name} (Pop: #{s.pop}) in #{s.nation}"
          # info s.inspect # Verbose

          city_data = {
            id: s.gid.to_s,
            code: s.code, # feature code
            name_translations: translate(s.name),
            pop: s.pop.to_i,
            geom: [s.lon.to_f, s.lat.to_f], # Ensure float for geoJSON
            postal: s.zip # tz
          }

          if region
            city_data[:region_id] = region.id.to_s
            # The Region object 'region' should now have its 'abbr' field populated
            # by the 'parse_region' method when it was created/updated.
            if region.respond_to?(:abbr) && region.abbr.present?
              city_data[:region_abbr] = region.abbr
            else
              warn "[CITY] Region '#{region.name}' (ID: #{region.id}) does NOT have an abbr for City '#{s.name}'"
            end
          else
            warn "[CITY WARN] No region found for city #{s.name} (Admin1 code: #{s.region}, Nation: #{s.nation})"
          end
          city_data
        end
      end
    end
  end
end

