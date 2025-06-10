require 'yaml'

module Geonames
  module Regions
    module Abbr
      # Path to the YML files for region abbreviations.
      ABBR_DATA_PATH = File.expand_path('abbr', __dir__)
      @loaded_abbrs = nil

      # Custom error for when a country's abbreviation data (YML) is not found.
      class UnsupportedCountryError < StandardError; end

      # Loads all .yml files from the ABBR_DATA_PATH.
      # The data is structured as:
      # {
      #   "us" => { "CA" => "California", "NY" => "New York", ... },
      #   "br" => { "SP" => "São Paulo", "MG" => "Minas Gerais", ... }
      # }
      # Keys are lowercase country codes, then uppercase region abbr, value is full region name.
      # This method is memoized.
      def self.load_abbreviations
        return @loaded_abbrs if @loaded_abbrs

        @loaded_abbrs = {}
        Dir.glob(File.join(ABBR_DATA_PATH, '*.yml')).each do |yaml_file|
          data = YAML.load_file(yaml_file)
          if data.is_a?(Hash) && data.keys.size == 1
            country_code_from_file = data.keys.first.to_s.downcase
            if data[data.keys.first].is_a?(Hash)
              @loaded_abbrs[country_code_from_file] ||= {}
              # Ensure region abbreviations (keys) are uppercase and names are strings
              data[data.keys.first].each do |abbr, name|
                @loaded_abbrs[country_code_from_file][abbr.to_s.upcase] = name.to_s
              end
            else
              warn "[Geonames::Regions::Abbr] Skipping invalid YML structure in #{yaml_file}: " \
                   'Expected a hash for country data under the top-level country key.'
            end
          else
            warn "[Geonames::Regions::Abbr] Skipping invalid YML structure in #{yaml_file}: " \
                 'Expected a single top-level key representing the country code.'
          end
        rescue StandardError => e
          warn "[Geonames::Regions::Abbr] Error loading YML file #{yaml_file}: #{e.message}"
        end
        @loaded_abbrs
      end

      # Retrieves the abbreviation for a given region name and country code.
      # Relies exclusively on YML data; no heuristics are used.
      #
      # @param region_name [String] The full name of the region (e.g., "California").
      #        This name must exactly match the value in the corresponding YML file (case-sensitive).
      # @param country_code [String, Symbol] The ISO 3166-1 alpha-2 country code (e.g., "us", "BR").
      # @return [String, nil] The uppercase 2-letter abbreviation if found, otherwise nil.
      # @raise [ArgumentError] If region_name or country_code is empty.
      # @raise [UnsupportedCountryError] If no YML data is found for the given country_code.
      def self.get_abbr(region_name, country_code)
        r_name = region_name.to_s
        c_code = country_code.to_s

        raise ArgumentError, 'Region name cannot be empty.' if r_name.empty?
        raise ArgumentError, 'Country code cannot be empty.' if c_code.empty?

        all_abbreviations = load_abbreviations # Ensures @loaded_abbrs is populated

        country_key = c_code.downcase
        country_specific_abbrs = all_abbreviations[country_key]

        unless country_specific_abbrs
          raise UnsupportedCountryError,
                "Unsupported country: '#{c_code}'. No abbreviation data (YML file) found in #{ABBR_DATA_PATH}."
        end

        # country_specific_abbrs is a hash like { "CA" => "California", "NY" => "New York" }
        # Find the key (abbreviation) whose value exactly matches r_name.
        found_entry = country_specific_abbrs.find { |_abbr, name_from_yml| name_from_yml == r_name }

        found_entry ? found_entry.first : nil # Returns the abbreviation (key) or nil
      end

      # Clears the loaded abbreviations cache. Useful for testing or reloading data.
      def self.reset_abbreviations!
        @loaded_abbrs = nil
      end
    end
  end
end
