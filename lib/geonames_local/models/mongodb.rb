require 'mongoid_geospatial'
require 'geopolitical'
require 'geopolitical/../../app/models/concerns/geopolitocracy'
require 'geopolitical/../../app/models/nation'
require 'geopolitical/../../app/models/region'
require 'geopolitical/../../app/models/city'
require 'geopolitical/../../app/models/hood'
require_relative '../regions/abbr' # Added to access the new Abbr module

Mongoid.configure do |config|
  # config.master = Mongo::Connection.new.db("symbolize_test")

  db_settings = Geonames::Opt[:db]
  puts db_settings.inspect #if Opt[:debug]

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

  # The config.connect_to call is generally not needed when setting config.clients.default
  # directly, as the database name is part of the client's configuration.
  # Mongoid will use the 'default' client by default.
end

module Geonames
  module Models
    module MongoWrapper
      class << self
        def batch(data)
          # Separate spots by their determined kind (:region, :city, :other)
          # Note: data is already grouped by kind from CLI's unify! and group_by(&:kind)
          # However, the 'kind' from Spot.human_code might be too coarse.
          # We need to re-evaluate based on feature_class and feature_code for hoods.

          # First, process regions and cities as before
          # The `data` parameter is expected to be a hash like { :region => [...], :city => [...] }
          # or potentially { :other => [...] } if human_code produced that.

          (data[:region] || []).each { |r_spot| create Region, parse_region(r_spot) }

          (data[:city] || []).each do |c_spot|
            city_pop = c_spot.pop.to_i
            min_pop_threshold = Opt[:min_pop].to_i
            if city_pop >= min_pop_threshold
              create City, parse_city(c_spot)
            else
              # info "[CITY SKIP] (#{c_spot.gid}) #{c_spot.name} (Pop: #{city_pop}) does not meet min_pop: #{min_pop_threshold}"
              print "."
            end
          end

          # Now, process potential hoods from spots that were not primary regions or cities.
          # This assumes `data` might contain an array of all spots if not pre-grouped,
          # or we might need to access all original spots before they were grouped by human_code.
          # For this iteration, let's assume `data[:other]` might contain them,
          # or we iterate through all spots if `data` is a flat array.
          # A better approach would be to get *all* spots from the Dump.new result before grouping.

          # Let's refine this: the `data` passed to batch is already grouped by the output of `human_code`.
          # So, spots classified as `:other` by `human_code` are candidates for hoods.
          (data[:other] || []).each do |spot|
            # Identify neighborhoods based on feature class and code
            # Example: PPLX (Section of populated place)
            # You might want to add other codes like ADM3, ADM4 if they represent neighborhoods in your target areas.
            if spot.feature_class == 'P' && spot.feature_code == 'PPLX'
              info "[HOOD CANDIDATE] Parsing PPLX: #{spot.name} (GID: #{spot.gid})"
              create Hood, parse_hood(spot)
            # Add other conditions for neighborhood feature codes if needed
            # elsif spot.feature_class == 'A' && ['ADM3', 'ADM4'].include?(spot.feature_code)
            #   info "[GEO HOOD CANDIDATE] Parsing ADM: #{spot.name} (GID: #{spot.gid})"
            #   create Hood, parse_hood(spot)
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
          if dup.changes.empty?
            print " "
          else
            warn " #{dup.changes}..."
          end
        rescue Mongoid::Errors::DocumentNotFound
          print " "
          print data.inspect if Opt[:verbose]
          klass.create! data
        rescue => e
          warn "[SPOT ERR] #{e} #{e.backtrace.reverse.join("\n")}"
          warn "[SPOT #{klass}] #{data}"
        end


        def translate(primary_name, geoname_id_str)
          # Ensure geoname_id is an integer for cache lookup
          geoname_id = geoname_id_str.to_s.match?(/^\d+$/) ? geoname_id_str.to_i : nil

          name_i18n = Opt[:locales].reduce({}) do |h, locale_code|
            translated_name = primary_name # Default to primary name

            if geoname_id &&
               Geonames::Cache[:alternate_names] &&
               Geonames::Cache[:alternate_names][geoname_id] &&
               (cached_entry = Geonames::Cache[:alternate_names][geoname_id][locale_code]) # Assign to var
              translated_name = cached_entry[:name] # Access the name from the hash
            elsif geoname_id.nil?
              # This case should ideally not happen if GID is always available
              # Geonames.info "[WARN] translate called with nil geoname_id for primary_name: #{primary_name}"
            end
            h.merge(locale_code => translated_name)
          end
          name_i18n
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
          # info "#{row}"
          # info "------------------------"
          {
            id: abbr,
            name_translations: translate(name, gid), # Existing translations
            postal: pos_code,
            cash: cur_code,
            gid: gid,
            souls: pop.to_i,
            abbr: abbr,
            code: iso3,
            langs: langs.to_s.split(',')
          }
        end

        #
        # Parse Regions
        #
        def parse_region(r)
          nation = Nation.find_by(abbr: /#{r.nation}/i)
          region_abbr = Geonames::Regions::Abbr.get_abbr(r.name, r.nation)

          parsed_data = {
            id: r.gid.to_s,
            name_translations: translate(r.name, r.gid), # Existing translations
            # The r.abbr might be from the input data source,
            # we prioritize our new logic via region_abbr.
            # If the Region model itself has an 'abbr' field, this will set it.
            abbr: region_abbr,
            souls: r.pop.to_i,
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

          # info "[CITY] #{s.gid} | #{s.name} / #{region&.abbr} #{region&.name} (Pop: #{s.pop}) in #{s.nation}"
          # info s.inspect # Verbose

          city_data = {
            id: s.gid.to_s,
            name_translations: translate(s.name, s.gid), # Existing translations
            code: s.code, # feature code
            souls: s.pop.to_i,
            geom: [s.lon.to_f, s.lat.to_f], # Ensure float for geoJSON
            postal: s.zip # tz
          }

          if region
            city_data[:region_id] = region.id.to_s
            if region.respond_to?(:abbr) && region.abbr.present?
              city_data[:region_abbr] = region.abbr
              # Construct slug with city name and region abbreviation
              # Slug will be handled by Geopolitical
            end
          end
          city_data
        end

        #
        # Parse Hoods (Neighborhoods)
        #
        def parse_hood(s) # s is a Geonames::Spot object

          # Attempt to find parent city - THIS IS A COMPLEX PART and needs specific logic
          # For now, let's assume we might try to find it via admin codes if available on the spot
          parent_city = nil
          if s.nation && s.region # s.region is admin1_code
            # We'd need a way to map s.nation (country_abbr) and s.region (admin1_code)
            # and potentially s.code (admin2_code on spot) to a City record.
            # This is highly dependent on how City records store their hierarchy.
            # Example placeholder:
            # nation_obj = Nation.find_by(abbr: /#{s.nation}/i)
            # if nation_obj
            #   city_region_obj = Region.find_by(code: s.region, nation_id: nation_obj.id) # Find ADM1
            #   if city_region_obj && s.code # s.code is admin2_code
            #      parent_city = City.where(admin2_code: s.code, region_id: city_region_obj.id).first # Hypothetical
            #   end
            # end
            # if parent_city
            #   info "[GEO HOOD] Found potential parent city for #{s.name}: #{parent_city.name}"
            # else
            #   warn "[GEO HOOD WARN] No parent city found for hood #{s.name} (Admin1: #{s.region}, Admin2: #{s.code}, Nation: #{s.nation})"
            # end
          end

          hood_data = {
            id: s.gid.to_s, # Use Geonames ID as the hood's ID
            name: s.name,
            name_translations: translate(s.name, s.gid),
            souls: s.pop.to_i, # Population, if available for the PPLX
            geom: [s.lon.to_f, s.lat.to_f],
            # feature_class: s.feature_class, # Optionally store these if your Hood model has fields for them
            # feature_code: s.feature_code,
          }

          # if parent_city
          #   hood_data[:city_id] = parent_city.id.to_s # Or however your Hood model links to City
          # end

          # Add other hood-specific fields from the Spot object if needed
          # hood_data[:some_other_field] = s.some_other_attribute

          hood_data
        end
      end
    end
  end
end

